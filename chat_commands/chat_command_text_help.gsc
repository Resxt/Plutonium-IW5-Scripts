#include scripts\chat_commands;

Init()
{
    CreateCommand(level.commands_servers_ports, "help", "text", ["Type " + level.commands_prefix + "commands to get a list of commands", "Type " + level.commands_prefix + "help followed by a command name to see how to use it"]);
}