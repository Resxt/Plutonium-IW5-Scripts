# Chat commands

Let players execute commands by typing in the chat.  
This can be used to display text to the player, for example the server rules or execute GSC code, just like console commands.  
This has been created for private games or servers that aren't running IW4MAdmin and want to have some commands.  
This hasn't been tested on a server running IW4MAdmin so I highly recommend doing some testing on a private server if you want to use both.  

**[IMPORTANT]** Installing `chat_commands.gsc` is **mandatory** to make the commands work as this is the core of this whole system and all the command scripts depend on it.  
Also note that this script doesn't provide any command on its own. You must install at least one command script to be able to use commands. Otherwise it will always say that you don't have any command.

:white_check_mark: Features available

- Easy per server (port) commands configuration. You can either pass an array of one server port, or multiple, or the `level.commands_servers_ports` array to easily add a command to one/multiple/all servers
- Chat text print and functions support
- All exceptions are handled with error messages (no commands on the server, not enough arguments, command doesn't exist, command doesn't have any help message, player doesn't exist etc.)
- A `commands` command that lists all available commands on the server you're on dynamically
- A `help` command that explains how to use a given command. For example `help map`
- Configurable command prefix. Set to `!` by default
- A plugin system to easily allow adding/removing commands. Each command has its own GSC file to easily add/remove/review/configure your commands. This also makes contributing by creating a PR to add a command a lot easier

:no_entry_sign: Features not available/to add

- Commands aliases
- Permissions/ranks to restrict some commands to a certain type of players (admin, VIP etc.)
- Configurable text colors/accent. As of now the majority of the text will be white

## chat_command_change_team.gsc

The player affected by the command dies and swaps to the other team.  

Arguments expected: the complete name of a player.  
Example: `!changteam Resxt`

## chat_command_freeze.gsc

Toggles whether the targeted player can move or not.  
Note that this does not work during the prematch period.  
Also, if you unfreeze a bot the bot has to die before he starts moving again.

| Examples |
|---|
| `!freeze me` |
| `!freeze Resxt` |

## chat_command_invisible.gsc

Toggles invisibility on the targeted player.  
Note that this does not make the player invisible to bots in the sense that even if they can't see the player, they will still know his position and shoot him.

| Examples |
|---|
| `!invisible me` |
| `!invisible Resxt` |

## chat_command_map_mode.gsc

3 related commands in one file:  

- Change map
- Change mode
- Change map and mode

| Name | Description | Arguments expected | Example |
|---|---|---|---|
| map | Changes the map on the server | (1) the map codename | `!map mp_dome` |
| mode | Charges a new DSR/mode on the server and restarts the current map | (1) the DSR file name, found in the `admin` folder of your game | `!mode FFA_default` |
| mapmode | Charges a new DSR/mode on the server and rotates to the requested map | (1) the map codename (2) the DSR file name, found in the `admin` folder of your game | `!mapmode mp_seatown TDM_default` |

## chat_command_norecoil.gsc

Toggles norecoil on the targeted player

| Examples |
|---|
| `!norecoil me` |
| `!norecoil Resxt` |

## chat_command_suicide.gsc

The player who runs the command dies.  

Arguments expected: none.  
Example: `!suicide`

## chat_command_teleport.gsc

Teleports a player to another

Arguments expected: (1) the name of the player to teleport (2) the name of the player to teleport to.  

| Examples |
|---|
| `!teleport me Eldor` |
| `!teleport Eldor me` |
| `!teleport Eldor Rektinator` |

## chat_command_text_rules.gsc

Prints the server rules in the player's chat.  
Arguments expected: none.  
Example: `!rules`

## chat_command_wallhack.gsc

Toggles wallhack (red boxes) on the targeted player

| Examples |
|---|
| `!wallhack me` |
| `!wallhack Resxt` |

## chat_commands.gsc

The core script that holds the configuration, runs all the chat logic and holds utils function that are shared between all the `chat_command` scripts.
