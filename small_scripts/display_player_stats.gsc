#include maps\mp\gametypes\_hud_util;


init()
{
    level thread OnPlayerConnected();
}

OnPlayerConnected()
{
    for(;;)
    {
        level waittill("connected", player);  

        if (isDefined(self.pers["isBot"]))
		{
			if (self.pers["isBot"])
			{
				return;
			}
		}

        player thread DisplayPlayerKillstreak();
    }
}	


DisplayPlayerKillstreak()
{
    self endon ("disconnect");
    level endon("game_ended");

    self.hudkillstreak = createFontString( "Objective", 0.65 );
    self.hudkillstreak setPoint( "CENTER", "TOP", "CENTER", 10 );

    while(true)
    {
        if(self.playerstreak != self.pers["cur_kill_streak"])
        {
            self.playerstreak = self.pers["cur_kill_streak"];
            self.hudkillstreak setText("^1KILLSTREAK: " + self.pers["cur_kill_streak"] + " | KILLS: " + self.pers["kills"] + " | DEATHS: " + self.pers["deaths"]);
        }

    wait 0.01;
    }
}