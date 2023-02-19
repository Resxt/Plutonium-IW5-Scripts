#include scripts\chat_commands;

Init()
{
    CreateCommand(level.commands_servers_ports, "unfairaimbot", "function", ::UnfairAimbotCommand, ["default_help_one_player"]);
}



/* Command section */

UnfairAimbotCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleUnfairAimbot(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleUnfairAimbot(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "unfairaimbot";

    ToggleStatus(commandName, "Unfair Aimbot", player);

    if (GetStatus(commandName, player))
    {
        player thread DoUnfairAimbot(true);
        player thread ThreadUnfairAimbot();
    }
    else
    {
        player notify("chat_commands_unfair_aimbot_off");
    }
}

ThreadUnfairAimbot()
{
    self endon("disconnect");
    self endon("chat_commands_unfair_aimbot_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        self thread DoUnfairAimbot(true);
    }
}

DoUnfairAimbot(requiresAiming)
{
    self endon("death");
    self endon("disconnect");
    self endon("chat_commands_unfair_aimbot_off");

    while (true)
    {
        targetedPlayer = undefined;

        foreach(player in level.players)
        {
            if((player == self) || (level.teamBased && self.pers["team"] == player.pers["team"]) || (!isAlive(player))) // don't aim at yourself, allies and player that aren't spawned
            {
                continue; // skip
            }
            
            if(IsDefined(targetedPlayer))
            {
                if(Closer( self getTagOrigin( "j_head" ), player getTagOrigin( "j_head" ), targetedPlayer getTagOrigin( "j_head" )))
                {
                    targetedPlayer = player;
                }
            }
            else
            {
                targetedPlayer = player;
            }
        }

        if(IsDefined( targetedPlayer ))
        {
            if (!IsDefined(requiresAiming) || !requiresAiming || requiresAiming && self AdsButtonPressed())
            {
                self SetPlayerAngles(VectorToAngles(( targetedPlayer getTagOrigin( "j_head" )) - (self getTagOrigin( "j_head" ))));

                if(self AttackButtonPressed())
                {
                    // for normal (non headshot) kills replace "MOD_HEAD_SHOT" with "MOD_RIFLE_BULLET" and replace "head" with "torso"
                    targetedPlayer thread [[level.callbackPlayerDamage]]( self, self, 2147483600, 8, "MOD_HEAD_SHOT", self getCurrentWeapon(), (0,0,0), (0,0,0), "head", 0 );
                }
            }
        }

        wait 0.05;
    }
}