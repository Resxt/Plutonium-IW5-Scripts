#include scripts\chat_commands;

Init()
{
    CreateCommand(level.commands_servers_ports, "getdvar", "function", ::GetDvarCommand);
    CreateCommand(level.commands_servers_ports, "setdvar", "function", ::SetDvarCommand);
    CreateCommand(level.commands_servers_ports, "setclientdvar", "function", ::SetPlayerDvarCommand);
}



/* Command section */

GetDvarCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = GetServerDvar(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}

SetDvarCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = SetServerDvar(args[0], args[1], false);

    if (IsDefined(error))
    {
        return error;
    }
}

SetPlayerDvarCommand(args)
{
    if (args.size < 3)
    {
        return NotEnoughArgsError(3);
    }

    error = SetPlayerDvar(args[0], args[1], args[2]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

GetServerDvar(dvarName)
{
    if (DvarIsInitialized(dvarName))
    {
        self thread TellPlayer(["^5" + dvarName + " ^7is currently set to ^5" + GetDvar(dvarName)], 1);
    }
    else
    {
        return DvarDoesNotExistError(dvarName);
    }
}

SetServerDvar(dvarName, dvarValue, canSetUndefinedDvar)
{
    if (IsDefined(canSetUndefinedDvar) && canSetUndefinedDvar)
    {
        SetDvar(dvarName, dvarValue);
    }
    else
    {
        if (DvarIsInitialized(dvarName))
        {
            SetDvar(dvarName, dvarValue);
        }
        else
        {
            return DvarDoesNotExistError(dvarName);
        }
    }
}

SetPlayerDvar(playerName, dvarName, dvarValue)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    player SetClientDvar(dvarName, dvarValue);
}