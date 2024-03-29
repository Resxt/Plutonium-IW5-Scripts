#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "invisible", "function", ::InvisibleCommand, 3, ["default_help_one_player"]);
}



/* Command section */

InvisibleCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleInvisible(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleInvisible(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "invisible";

    ToggleStatus(commandName, "Invisible", player);

    if (GetStatus(commandName, player))
    {
        player hide();
    }
    else
    {
        player show();
    }
}