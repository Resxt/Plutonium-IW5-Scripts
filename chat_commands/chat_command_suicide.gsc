#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "suicide", "function", ::SuicideCommand, 1, [], ["s"]);
}



/* Command section */

SuicideCommand(args)
{
    self Suicide();
}