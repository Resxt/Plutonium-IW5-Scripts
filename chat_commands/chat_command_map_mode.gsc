#include scripts\chat_commands;

Init()
{
    CreateCommand(level.commands_servers_ports, "map", "function", ::ChangeMapCommand, ["Example: " + level.commands_prefix + "map mp_dome"]);
    CreateCommand(level.commands_servers_ports, "mode", "function", ::ChangeModeCommand, ["Example: " + level.commands_prefix + "mode FFA_default"]);
    CreateCommand(level.commands_servers_ports, "mapmode", "function", ::ChangeMapAndModeCommand, ["Example: " + level.commands_prefix + "mapmode mp_seatown TDM_default"]);
}



/* Command section */

ChangeMapCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    ChangeMap(args[0]);
}

ChangeModeCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    ChangeMode(args[0], true);
}

ChangeMapAndModeCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    ChangeMode(args[1], false);
    ChangeMap(args[0]);
}



/* Logic section */

ChangeMap(mapName)
{
    cmdexec("map " + mapName);
}

ChangeMode(modeName, restart)
{
    cmdexec("load_dsr " + modeName + ";");

    if (restart)
    {
        cmdexec("map_restart");
    }
}