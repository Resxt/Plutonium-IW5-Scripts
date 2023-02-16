/*
==========================================================================
|                           Game: Plutonium IW5                          |
|               Description : Display text and run GSC code              | 
|                      by typing commands in the chat                    |
|                             Author: Resxt                              |
==========================================================================
| https://github.com/Resxt/Plutonium-IW5-Scripts/tree/main/chat_commands |
==========================================================================
*/



/* Init section */

Main() 
{
    InitChatCommands();
}

InitChatCommands()
{
    level.commands = []; // don't touch
    level.commands_prefix = "!"; // the symbol to type before the command name in the chat. Only one character is supported. The slash (/) symbol won't work normally as it's reserved by the game. If you use the slash (/) you will need to type double slash in the game
    level.commands_servers_ports = ["27016", "27017", "27018"]; // an array of the ports of all your servers you want to have the script running on. This is useful to easily pass this array as first arg of CreateCommand to have the command on all your servers
    level.commands_no_commands_message = ["^1No commands found", "You either ^1didn't add any chat_command file ^7to add a new command ^1or ^7there are ^1no command configured on this port", "chat_commands.gsc is ^1just the base system. ^7It doesn't provide any command on its own", "Also ^1make sure the ports are configured properly ^7in the CreateCommand function of your command file(s)"]; // the lines to print in the chat when the server doesn't have any command added
    level.commands_no_commands_wait = 6; // time to wait between each line in <level.commands_no_commands_message> when printing that specific message in the chat

    level thread ChatListener();
}



/* Commands section */

/*
<serverPorts> the ports of the servers this command will be created for
<commandName> the name of the command, this is what players will type in the chat
<commandType> the type of the command: <text> is for arrays of text to display text in the player's chat and <function> is to execute a function
<commandValue> when <commandType> is "text" this is an array of lines to print in the chat. When <commandType> is "function" this is a function pointer (a reference to a function)
<commandHelp> an array of the lines to print when typing the help command in the chat followed by a command name. You can also pass an array of one preset string to have it auto generated, for example: ["default_help_one_player"] 
*/
CreateCommand(serverPorts, commandName, commandType, commandValue, commandHelp)
{
    foreach (serverPort in serverPorts)
    {
        level.commands[serverPort][commandName]["type"] = commandType;

        if (IsDefined(commandHelp))
        {
            commandHelpMessage = commandHelp;
            commandHelpString = commandHelp[0];
            
            if (commandHelpString == "default_help_one_player")
            {
                commandHelpMessage = ["Example: " + level.commands_prefix + commandName + " me", "Example: " + level.commands_prefix + commandName + " Resxt"];
            }
            else if (commandHelpString == "default_help_two_players")
            {
                commandHelpMessage = ["Example: " + level.commands_prefix + commandName + " me Resxt", "Example: " + level.commands_prefix + commandName + " Resxt me", "Example: " + level.commands_prefix + commandName + " Resxt Eldor"];
            }

            level.commands[serverPort][commandName]["help"] = commandHelpMessage;
        }
    
        if (commandType == "text")
        {
            level.commands[serverPort][commandName]["text"] = commandValue;
        }
        else if (commandType == "function")
        {
            level.commands[serverPort][commandName]["function"] = commandValue;
        }
    }
}



/* Chat section */

ChatListener()
{
    while (true) 
    {
        level waittill("say", message, player);

        if (message[0] != level.commands_prefix) // For some reason checking for the buggy character doesn't work so we start at the second character if the first isn't the command prefix
        {
            message = GetSubStr(message, 1); // Remove the random/buggy character at index 0, get the real message
        }

        if (message[0] != level.commands_prefix) // If the message doesn't start with the command prefix
        {
            continue; // stop
        }

        commandArray = StrTok(message, " "); // Separate the command by space character. Example: ["!map", "mp_dome"]
        command = commandArray[0]; // The command as text. Example: !map
        args = []; // The arguments passed to the command. Example: ["mp_dome"]

        for (i = 1; i < commandArray.size; i++)
        {
            args = AddElementToArray(args, commandArray[i]);
        }

        if (IsDefined(level.commands[GetDvar("net_port")]))
        {
            if (command == level.commands_prefix + "commands") // commands command
            {
                player thread TellPlayer(GetArrayKeys(level.commands[GetDvar("net_port")]), 2, true);
            }
            else
            {
                // help command
                if (command == level.commands_prefix + "help" && !IsDefined(level.commands[GetDvar("net_port")]["help"]) || command == level.commands_prefix + "help" && IsDefined(level.commands[GetDvar("net_port")]["help"]) && args.size >= 1)
                {
                    if (args.size < 1)
                    {
                        player thread TellPlayer(NotEnoughArgsError(1), 1.5);
                    }
                    else
                    {
                        commandValue = level.commands[GetDvar("net_port")][args[0]];

                        if (IsDefined(commandValue))
                        {
                            commandHelp = commandValue["help"];

                            if (IsDefined(commandHelp))
                            {
                                player thread TellPlayer(commandHelp, 1.5);
                            }
                            else
                            {
                                player thread TellPlayer(CommandHelpDoesNotExistError(args[0]), 1);
                            }
                        }
                        else
                        {
                            if (args[0] == "commands")
                            {
                                player thread TellPlayer(CommandHelpDoesNotExistError(args[0]), 1);
                            }
                            else
                            {
                                player thread TellPlayer(CommandDoesNotExistError(args[0]), 1);
                            }
                        }
                    }
                }
                // any other command
                else
                {
                    commandName = GetSubStr(command, 1);
                    commandValue = level.commands[GetDvar("net_port")][commandName];

                    if (IsDefined(commandValue))
                    {
                        if (commandValue["type"] == "text")
                        {
                            player thread TellPlayer(commandValue["text"], 2);
                        }
                        else if (commandValue["type"] == "function")
                        {
                            error = player [[commandValue["function"]]](args);

                            if (IsDefined(error))
                            {
                                player thread TellPlayer(error, 1.5);
                            }
                        }
                    }
                    else
                    {
                        player thread TellPlayer(CommandDoesNotExistError(commandName), 1);
                    }
                }
            }
        }
        else
        {
            player thread TellPlayer(level.commands_no_commands_message, level.commands_no_commands_wait, false);
        }
    }
}

TellPlayer(messages, waitTime, isCommand)
{
    for (i = 0; i < messages.size; i++)
    {
        message = messages[i];

        if (IsDefined(isCommand) && isCommand)
        {
            message = level.commands_prefix + message;
        }

        self tell(message);
        
        if (i < (messages.size - 1)) // Don't unnecessarily wait after the last message has been displayed
        {
            wait waitTime;
        }
    }
}



/* Error functions section */

CommandDoesNotExistError(commandName)
{
    return ["The command " + commandName + " doesn't exist", "Type " + level.commands_prefix + "commands to get a list of commands"];
}

CommandHelpDoesNotExistError(commandName)
{
    return ["The command " + commandName + " doesn't have any help message"];
}

NotEnoughArgsError(minimumArgs)
{
    return ["Not enough arguments supplied", "At least " + minimumArgs + " argument expected"];
}

PlayerDoesNotExistError(playerName)
{
    return ["Player " + playerName + " was not found"];
}



/* Utils section */

FindPlayerByName(name)
{
    if (name == "me")
    {
        return self;
    }
    
    foreach (player in level.players)
    {
        if (ToLower(player.name) == ToLower(name))
        {
            return player;
        }
    }
}

ToggleStatus(commandName, commandDisplayName, player)
{
    SetStatus(commandName, player, !GetStatus(commandName, player));

    statusMessage = "^2ON";
    
    if (!GetStatus(commandName, player))
    {
        statusMessage = "^1OFF";
    }

    if (self.name == player.name)
    {
        self TellPlayer(["You changed your " + commandDisplayName + " status to " + statusMessage], 1);
    }
    else
    {
        self TellPlayer([player.name + " " + commandDisplayName + " status changed to " + statusMessage], 1);
        player TellPlayer([self.name + " changed your " + commandDisplayName + " status to " + statusMessage], 1);
    }
}

GetStatus(commandName, player)
{
    if (!IsDefined(player.chat_commands)) // avoid undefined errors in the console
    {
        player.chat_commands = [];
    }

    if (!IsDefined(player.chat_commands["status"])) // avoid undefined errors in the console
    {
        player.chat_commands["status"] = [];
    }

    if (!IsDefined(player.chat_commands["status"][commandName])) // status is set to OFF/false by default
    {
        SetStatus(commandName, player, false);
    }

    return player.chat_commands["status"][commandName];
}

SetStatus(commandName, player, status)
{
    player.chat_commands["status"][commandName] = status;
}

AddElementToArray(array, element)
{
    array[array.size] = element;
    return array;
}