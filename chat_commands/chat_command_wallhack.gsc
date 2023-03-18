#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "wallhack", "function", ::WallhackCommand, 4, ["default_help_one_player"]);
}



/* Command section */

WallhackCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleWallhack(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleWallhack(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "wallhack";

    ToggleStatus(commandName, "Wallhack", player);

    if (GetStatus(commandName, player))
    {
        player DoWallhack(true);
        player thread ThreadWallhack();
    }
    else
    {
        player DoWallhack(false);
        player notify("chat_commands_wallhack_off");
    }
}

ThreadWallhack()
{
    self endon("disconnect");
    self endon("chat_commands_wallhack_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        DoWallhack(true);
    }
}

DoWallhack(enabled)
{
    if (enabled)
    {
        self ThermalVisionFOFOverlayOn();
    }
    else
    {
        self ThermalVisionFOFOverlayOff();
    }
}