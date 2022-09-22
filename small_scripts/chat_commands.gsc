/*
==========================================================================
|                           Game: Plutonium IW5 	                     |
|               Description : Display text and run GSC code              | 
|                      by typing commands in the chat                    |
|                             Author: Resxt                              |
==========================================================================
| https://github.com/Resxt/Plutonium-IW5-Scripts/tree/main/small_scripts |
==========================================================================
*/



/* Init section */

Init() 
{
    InitCommands();

    level thread ChatListener();
}

InitCommands()
{
    level.commands_prefix = "!";

    level.commands["27016"]["rules"] = ["Do not camp", "Do not spawnkill", "Do not disrespect other players"];
    level.commands["27016"]["suicide"] = ::SuicideCommand;
    level.commands["27016"]["map"] = ::ChangeMapCommand;
    level.commands["27016"]["mode"] = ::ChangeModeCommand;
    level.commands["27016"]["mapmode"] = ::ChangeMapAndModeCommand;
}



/* Chat section */

ChatListener()
{
    while (true) 
    {
        level waittill("say", message, player);

        message = GetSubStr(message, 1); // Remove the random/buggy character at index 0, get the real message

        if (message[0] != level.commands_prefix) // If the message doesn't start with the command prefix
        {
            continue; // Ignore/skip
        }

        commandArray = StrTok(message, " "); // Separate the command by space character. Example: ["!map", "mp_dome"]
        command = commandArray[0]; // The command as text. Example: !map
        args = []; // The arguments passed to the command. Example: ["mp_dome"]

        for (i = 1; i < commandArray.size; i++)
        {
            args[args.size] = commandArray[i];
        }

        if (command == level.commands_prefix + "commands")
        {
            player thread TellPlayer(GetArrayKeys(level.commands[GetDvar("net_port")]), 2, true);
        }
        else
        {
            commandValue = level.commands[GetDvar("net_port")][GetSubStr(command, 1)];

            if (IsDefined(commandValue))
            {
                if (IsDefined(commandValue.size))
                {
                    player thread TellPlayer(commandValue, 2);
                }
                else
                {
                    error = player [[commandValue]](args);

                    if (IsDefined(error))
                    {
                        player thread TellPlayer(error, 1.5);
                    }
                }
            }
            else
            {
                player thread TellPlayer(CommandDoesNotExistError(), 1);
            }
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



/* Command functions section */

SuicideCommand(args)
{
    self Suicide();
}

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



/* Logic functions section */

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



/* Error functions section */

CommandDoesNotExistError()
{
    return ["This command doesn't exist", "Type " + level.commands_prefix + "commands" + " to get a list of commands"];
}

NotEnoughArgsError(minimumArgs)
{
    return ["Not enough arguments supplied", "At least " + minimumArgs + " argument expected"];
}