#include scripts\chat_commands;

Init()
{
    CreateCommand(level.commands_servers_ports, "changeteam", "function", ::ChangeTeamCommand, ["default_help_one_player"]);
}



/* Command section */

ChangeTeamCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ChangeTeam(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ChangeTeam(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    if (player.team == "axis")
    {
        player [[level.allies]]();
    }
    else if (player.team == "allies")
    {
        player [[level.axis]]();
    }
}