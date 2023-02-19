#include scripts\chat_commands;

Init()
{
    CreateCommand(level.commands_servers_ports, "kill", "function", ::KillCommand, ["default_help_one_player"]);
}



/* Command section */

KillCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = KillPlayer(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

KillPlayer(targetedPlayerName)
{
    if (self TargetIsMyself(targetedPlayerName))
    {
        self Suicide();
    }
    else
    {
        player = FindPlayerByName(targetedPlayerName);

        if (!IsDefined(player))
        {
            return PlayerDoesNotExistError(targetedPlayerName);
        }

        playerTeam = self.team;
        self.team = "noteam"; // we change the player's team to bypass the friendly fire limitation

        player thread [[level.callbackPlayerDamage]]( self, self, 2147483600, 8, "MOD_SUICIDE", self getCurrentWeapon(), (0,0,0), (0,0,0), "torso", 0 );

        self.team = playerTeam; // sets the player's team to his original team again
    }    
}