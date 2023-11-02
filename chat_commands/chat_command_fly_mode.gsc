#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "flymode", "function", ::FlyModeCommand, 3, ["default_help_one_player"], ["fly"]);
}



/* Command section */

FlyModeCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleFlyMode(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleFlyMode(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "fly";

    ToggleStatus(commandName, "Fly Mode", player);

    if (GetStatus(commandName, player))
    {
        player DoFlyMode(true);
        player thread ThreadFlyMode();
    }
    else
    {
        player DoFlyMode(false);
        player notify("chat_commands_fly_mode_off");
    }
}

ThreadFlyMode()
{
    self endon("disconnect");
    self endon("chat_commands_fly_mode_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        self DoFlyMode(true);
    }
}

DoFlyMode(enabled)
{
    if (enabled)
    {
        if ( self.sessionstate == "playing" ) 
        {
            self allowSpectateTeam( "freelook", true );
            self.sessionstate = "spectator";
        } else {
            self.sessionstate = "playing";
            self allowSpectateTeam( "freelook", false );
        }
    }
    else
    {
        if ( self.sessionstate == "playing" ) 
        {
            self allowSpectateTeam( "freelook", true );
            self.sessionstate = "spectator";
        } else {
            self.sessionstate = "playing";
            self allowSpectateTeam( "freelook", false );
        }
    }
}