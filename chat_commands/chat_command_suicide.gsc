#include scripts\chat_commands;

Init()
{
    CreateCommand(["27016", "27017"], "suicide", "function", ::SuicideCommand);
}



/* Command section */

SuicideCommand(args)
{
    self Suicide();
}