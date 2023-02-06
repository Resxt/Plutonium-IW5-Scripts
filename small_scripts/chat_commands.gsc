/*
==========================================================================
|                           Game: Plutonium IW5                          |
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
    InitChatCommands();
}

InitChatCommands()
{
    level.commands_prefix = "!";
    level.commands_servers_ports = ["27016", "27017", "27018"];

    InitCommands();

    level thread ChatListener();
}

InitCommands()
{
    // All servers text commands
    CreateCommand(level.commands_servers_ports, "help", "text", ["Type " + level.commands_prefix + "commands to get a list of commands", "Type " + level.commands_prefix + "help followed by a command name to see how to use it"]);

    // All servers function commands
    CreateCommand(level.commands_servers_ports, "map", "function", ::ChangeMapCommand, ["Example: " + level.commands_prefix + "map mp_dome"]);
    CreateCommand(level.commands_servers_ports, "mode", "function", ::ChangeModeCommand, ["Example: " + level.commands_prefix + "mode FFA_default"]);
    CreateCommand(level.commands_servers_ports, "mapmode", "function", ::ChangeMapAndModeCommand, ["Example: " + level.commands_prefix + "mapmode mp_seatown TDM_default"]);
    CreateCommand(level.commands_servers_ports, "changeteam", "function", ::ChangeTeamCommand, "default_help_one_player");
    CreateCommand(level.commands_servers_ports, "teleport", "function", ::TeleportCommand, "default_help_two_players");
    CreateCommand(level.commands_servers_ports, "norecoil", "function", ::NoRecoilCommand, "default_help_one_player");
    CreateCommand(level.commands_servers_ports, "invisible", "function", ::InvisibleCommand, "default_help_one_player");
    CreateCommand(level.commands_servers_ports, "wallhack", "function", ::WallhackCommand, "default_help_one_player");

    // Specific server(s) text commands
    CreateCommand(["27016", "27017"], "rules", "text", ["Do not camp", "Do not spawnkill", "Do not disrespect other players"]);
    CreateCommand(["27018"], "rules", "text", ["Leave your spot and don't camp after using a M.O.A.B", "Don't leave while being infected", "Do not disrespect other players"]);

    // Specific server(s) function commands
    CreateCommand(["27016", "27017"], "suicide", "function", ::SuicideCommand);
}

/*
<serverPorts> the ports of the servers this command will be created for
<commandName> the name of the command, this is what players will type in the chat
<commandType> the type of the command: <text> is for arrays of text to display text in the player's chat and <function> is to execute a function
*/
CreateCommand(serverPorts, commandName, commandType, commandValue, commandHelp)
{
    foreach (serverPort in serverPorts)
    {
        level.commands[serverPort][commandName]["type"] = commandType;

        if (IsDefined(commandHelp))
        {
            commandHelpMessage = commandHelp;
            
            if (commandHelp == "default_help_one_player")
            {
                commandHelpMessage = ["Example: " + level.commands_prefix + commandName + " me", "Example: " + level.commands_prefix + commandName + " Resxt"];
            }
            else if (commandHelp == "default_help_two_players")
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

        // commands command
        if (command == level.commands_prefix + "commands")
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

ChangeTeamCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ChangeTeam(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}

TeleportCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = TeleportPlayer(args[0], args[1]);

    if (IsDefined(error))
    {
        return error;
    }
}

NoRecoilCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleNoRecoil(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}

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

ChangeTeam(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    if (player.team == "axis")
    {
        player [[level.allies]]();
    }
    else if (player.team == "allies")
    {
        player [[level.axis]]();
    }
}

TeleportPlayer(teleportedPlayerName, destinationPlayerName)
{
    players = [];
    names = [teleportedPlayerName, destinationPlayerName];

    for (i = 0; i < names.size; i++)
    {
        name = names[i];

        player = FindPlayerByName(name);

        if (!IsDefined(player))
        {
            return PlayerDoesNotExistError(name);
        }

        players = AddElementToArray(players, player);
    }

    players[0] SetOrigin(players[1].origin);
}

ToggleNoRecoil(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    recoilModifier = 100;

    if (IsDefined(player.recoilscale) && player.recoilscale == 100)
    {
        recoilModifier = 0;
    }

    player maps\mp\_utility::setrecoilscale( recoilModifier, recoilModifier );
    player.recoilscale = recoilModifier;

    ToggleStatus("no_recoil", "No Recoil", player);
}

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