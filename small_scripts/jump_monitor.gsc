//#include maps\mp\bots\_bot_utility; // Uncomment if using Bot Warfare
//#include maps\mp\bots\_bot_internal; // Uncomment if using Bot Warfare
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\_utility;

Init()
{
    InitJumpMonitor();
}

InitJumpMonitor()
{
    level.jump_monitor_is_monitoring = false; // don't touch, this is used to only start the timer after prematch is over
    level.jump_monitor_bot_wait_time = 3.25;

    level thread OnPlayerConnect();
    level thread OnPrematchOver();
}

OnPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);

        player thread OnPlayerSpawned();
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("changed_kit");

        if (!self IsBot() && level.jump_monitor_is_monitoring)
        {
            self MonitorPlayerJump();
        }
        else if (self IsBot() && level.jump_monitor_is_monitoring)
        {
            self thread MonitorBotJump();
        }
    }
}

MonitorPlayerJump()
{
    self thread MonitorTimer();

    self.pers["ground_status"] = "ground";
    self notify("is_on_ground");

    self thread MonitorGround();
}

MonitorBotJump()
{
    self endon("disconnect");
    self endon("death");
    
    for(;;)
    {
        wait level.jump_monitor_bot_wait_time;
        //self thread jump(); // Uncomment if using Bot Warfare
    }
}

MonitorTimer()
{
    self endon("disconnect");
    self endon("death");

    for(;;)
    {
        groundStatus = self waittill_any_return("is_on_ground", "is_not_on_ground");

        if (groundStatus == "is_on_ground")
        {
            self thread JumpTimer();
        }
    }
}

MonitorGround()
{
    self endon("disconnect");
    self endon("death");

    while (true)
    {
        if (self IsOnGround() && self.pers["ground_status"] != "on_ground")
        {
            self.pers["ground_status"] = "on_ground";
            self notify("is_on_ground");
        }
        else if (!self IsOnGround() && self.pers["ground_status"] != "not_on_ground")
        {
            self.pers["ground_status"] = "not_on_ground";
            self notify("is_not_on_ground");
        }

        wait 0.01;
    }
}

OnPrematchOver()
{
    for(;;)
    {
        level waittill( "prematch_over" );

        level.jump_monitor_is_monitoring = true;

        foreach (player in level.players)
        {
            if (!player IsBot() && IsReallyAlive(player))
            {
                player MonitorPlayerJump();
            }
            else if (player IsBot() && IsReallyAlive(player))
            {
                player thread MonitorBotJump();
            }
        }
    }
}

JumpTimer()
{
    self endon("disconnect");
    self endon("death");
    self endon("is_not_on_ground");

    time = 7.5;
    soundStartTime = (time / 2);
    tick = 0.25;

    while(time != 0)
    {
        wait tick;
        time -= tick;
        
        if(time <= (soundStartTime) && time != 0)
        {
            self playlocalsound("ui_mp_suitcasebomb_timer");
        }
    }

    self playsound("detpack_explo_default");

    playfx(level.c4death, self.origin);

    self suicide();
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}