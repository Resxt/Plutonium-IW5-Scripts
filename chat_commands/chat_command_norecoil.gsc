#include scripts\chat_commands;

Init()
{
    CreateCommand(level.commands_servers_ports, "norecoil", "function", ::NoRecoilCommand, ["default_help_one_player"]);
}



/* Command section */

NoRecoilCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleNoRecoil(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleNoRecoil(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    recoilModifier = 100;

    if (IsDefined(player.recoilscale) && player.recoilscale == 100)
    {
        recoilModifier = 0;
    }

    player maps\mp\_utility::setrecoilscale( recoilModifier, recoilModifier );
    player.recoilscale = recoilModifier;

    ToggleStatus("no_recoil", "No Recoil", player);
}