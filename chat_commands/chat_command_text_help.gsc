#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "help", "text", ["Type " + level.chat_commands["prefix"] + "commands to get a list of commands", "Type " + level.chat_commands["prefix"] + "help followed by a command name to see how to use it"], 1);
}