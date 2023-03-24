# Chat commands

Let players execute commands by typing in the chat.  
This can be used to display text to the player, for example the server rules or execute GSC code, just like console commands.  
This works in private games, on dedicated servers that use [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin) and those that don't.  
If you do monitor your server with [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin) then make sure to read the [notes section](#notes).

## chat_commands.gsc

The core script that holds the configuration, runs all the chat logic and holds utils function that are shared between all the `chat_command` scripts.  
**[IMPORTANT]** Installing it is **mandatory** to make the commands work as this is the core of this whole system and all the command scripts depend on it.  
Also note that this script doesn't provide any command on its own. You must install at least one command script to be able to use commands. Otherwise it will always say that you don't have any command.

### Main features

- Easy per server (port) commands configuration. You can either pass an array of one server port, or multiple, or the `level.chat_commands["ports"]` array to easily add a command to one/multiple/all servers
- Chat text print and functions support
- Optional permissions level system to restrict commands to players with a certain permission level (disabled by default)
- All exceptions are handled with error messages (no commands on the server, not enough arguments, command doesn't exist, command doesn't have any help message, player doesn't exist etc.)
- A `commands` command that lists all available commands on the server you're on dynamically (only lists commands you have access to if the permission system is enabled)
- A `help` command that explains how to use a given command. For example `help map` (only works on commands you have access to if the permission system is enabled)
- All commands that require a target work with `me`. Also it doesn't matter how you type the player's name as long as you type the full name.
- Configurable command prefix. Set to `!` by default
- A plugin system to easily allow adding/removing commands. Each command has its own GSC file to easily add/remove/review/configure your commands. This also makes contributing by creating a PR to add a command a lot easier

### Dvars

Here are the dvars you can configure:
  
| Name | Description | Default value | Accepted values |
|---|---|---|---|
| cc_debug | Toggle whether the script is in debug mode or not. This is used to print players GUID in the console when they connect | 0 | 0 or 1 |
| cc_prefix | The symbol to type before the command name in the chat. Only one character is supported. The `/` symbol won't work normally as it's reserved by the game. If you use the `/` symbol as prefix you will need to type double slash in the game | ! | Any working symbol |
| cc_permission_enabled | Toggle whether the permission system is enabled or not. If it's disabled any player can run any available command | 0 | 0 or 1 |
| cc_permission_mode | Changes whether the permission dvars values are names or guids | name | name or guid |
| cc_permission_default | The default permission level players who aren't found in the permission dvars will be granted | 1 | Any plain number from 0 to `cc_permission_max` |
| cc_permission_max | The maximum/most elevated permission level | 4 | Any plain number above 0 |
| cc_permission_0 | A list of names or guids of players who will be granted the permission level 0 when connecting (no access to any command) | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |
| cc_permission_1 | A list of names or guids of players who will be granted the permission level 1 when connecting  | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |
| cc_permission_2 | A list of names or guids of players who will be granted the permission level 2 when connecting  | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |
| cc_permission_3 | A list of names or guids of players who will be granted the permission level 3 when connecting  | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |
| cc_permission_4 | A list of names or guids of players who will be granted the permission level 4 when connecting  | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |

### Configuration

Below is an example CFG showing how each dvars can be configured.  
The values you see are the default values that will be used if you don't set a dvar.  

```c
set cc_debug 0
set cc_prefix "!"
set cc_permission_enabled 0
set cc_permission_mode "name"
set cc_permission_default 1
set cc_permission_max 4
set cc_permission_0 ""
set cc_permission_1 ""
set cc_permission_2 ""
set cc_permission_3 ""
set cc_permission_4 ""
```

### Notes

- To pass an argument with a space you need to put `'` around it. For example if a player name is `The Moonlight` then you would write `!teleport 'The Moonlight' Resxt`
- If you use [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin) make sure you have a different commands prefix to avoid conflicts. For example `!` for IW4MAdmin commands and `.` for this script. The commands prefix can be modified by changing the value of the `cc_prefix` dvar. As for [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin), at the time of writing, if you want to change it you'll need to change the value of [CommandPrefix](https://github.com/RaidMax/IW4M-Admin/wiki/Configuration#advanced-configuration)
- If you prefer to display information (error messages, status change etc.) on the player's screen rather than in the chat you can edit the `TellPlayer` function. For this you simply need to change `self tell(message);` to `self IPrintLnBold(message);`

## chat_command_change_team.gsc

The player affected by the command dies and swaps to the other team.  

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to swap to the other team | :white_check_mark: |

| Examples |
|---|
| `!changeteam me` |
| `!changeteam Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_dvars.gsc

3 related commands in one file:  

- Print server dvar
- Change server dvar
- Change client dvar

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| getdvar | Prints the (server) dvar value in the player's chat | (1) the dvar name | `!getdvar g_speed` | 2 |
| setdvar | Changes a dvar on the server | (1) the dvar name (2) the new dvar value | `!setdvar jump_height 500` | 4 |
| setclientdvar | Changes a dvar on the targeted player | (1) the name of the player (2) the dvar name (3) the new dvar value | `!setclientdvar Resxt cg_thirdperson 1` | 4 |

## chat_command_freeze.gsc

Toggles whether the targeted player can move or not.  
Note that this does not work during the prematch period.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to freeze/unfreeze | :white_check_mark: |

| Examples |
|---|
| `!freeze me` |
| `!freeze Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_give.gsc

3 related commands in one file:  

- Give weapon
- Give killstreak
- Give camo

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| giveweapon | Gives the specified weapon to the targeted player. Removes the current weapon and plays the switch animation by default | (1) the name of the targeted player (2) the weapon code name (attachments and camos accepted too) | `!giveweapon me iw5_acr_mp_reflex_camo11` | 2 |
| givekillstreak | Gives the specified killstreak to the targeted player | (1) the name of the targeted player (2) the killstreak code name | `!givekillstreak me predator_missile` | 3 |
| givecamo | Changes the camo of all the primary weapons the targeted player has to the specified camo. Plays the switch animation by default | (1) the name of the targeted player (2) the name of the camo or its index | `!givecamo me gold` | 2 |

You can check [this](https://www.itsmods.com/forum/Thread-Tutorial-MW3-weapons-perks-camos-attachments.html) to get weapon/killstreak/camos names.  

Note that for weapons you need to add `_mp` at the end of the weapon name.  
So for example if the website says `iw5_scar` you would replace it with `iw5_scar_mp`.  
This is only for the weapon name, if you add an attachment and/or a camo `_mp` would still be at the same position, it wouldn't be at the end.  
For example a SCAR-L with an acog sight and the red camo would be `iw5_scar_mp_acog_camo09`.  

The format is `<weapon_name>_<attachment>_<camo>`.  

Note that default snipers scope are considered as attachments.  
You can find the list of sniper scopes by taking a look at the `GetDefaultWeaponScope` function of my [gun game script](https://github.com/Resxt/Plutonium-IW5-Scripts/blob/main/gamemodes/gun_game.gsc).  

If you add multiple attachments then you need to respect an order that entirely depends on the weapon and attachments.  
It would be too long to explain so I would recommend simply not bothering with multiple attachments or taking a look at the `FixReversedAttachments` function of my [gun game script](https://github.com/Resxt/Plutonium-IW5-Scripts/blob/main/gamemodes/gun_game.gsc)

| More examples |
|---|
| `!giveweapon me iw5_fad_mp` |
| `!giveweapon me iw5_ak74u_mp_reflexsmg_camo11` |
| `!giveweapon Resxt iw5_cheytac_mp_cheytacscope_camo08` |
| `!givecamo me red` |
| `!givecamo me none` |
| `!givecamo Resxt 11` |

## chat_command_god_mode.gsc

Toggles whether the targeted player is in god mode (invincible) or not.  

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle god mode for | :white_check_mark: |

| Examples |
|---|
| `!god me` |
| `!god Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_invisible.gsc

Toggles invisibility on the targeted player.  
Note that this does not make the player invisible to bots in the sense that even if they can't see the player, they will still know his position and shoot him.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to make invisible/visible | :white_check_mark: |

| Examples |
|---|
| `!invisible me` |
| `!invisible Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_kill.gsc

The player who runs the command kills the targeted player (no matter if they're in the same team or not)

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to kill | :white_check_mark: |

| Examples |
|---|
| `!kill me` |
| `!kill Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_map_mode.gsc

3 related commands in one file:  

- Change map
- Change mode
- Change map and mode

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| map | Changes the map on the server | (1) the map codename | `!map mp_dome` | 4 |
| mode | Charges a new DSR/mode on the server and restarts the current map | (1) the DSR file name, found in the `admin` folder of your game | `!mode FFA_default` | 4 |
| mapmode | Charges a new DSR/mode on the server and rotates to the requested map | (1) the map codename (2) the DSR file name, found in the `admin` folder of your game | `!mapmode mp_seatown TDM_default` | 4 |

## chat_command_norecoil.gsc

Toggles norecoil on the targeted player

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle norecoil for | :white_check_mark: |

| Examples |
|---|
| `!norecoil me` |
| `!norecoil Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_permissions.gsc

2 related commands in one file:  

- Get permission level
- Set permission level

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| getpermission | Prints the targeted player's current permission level in the player's chat | (1) the name of the targeted player | `!getpermission me` | 2 |
| setpermission | Changes the targeted player's permission level (for the current game only) | (1) the name of the targeted player (2) the permission level to grant | `!setpermission Resxt 4` | 4 |

## chat_command_suicide.gsc

The player who runs the command dies.  

| Example |
|---|
| `!suicide` |

| Permission level |
|---|
| 1 |

## chat_command_teleport.gsc

Teleports a player to the position of another player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to teleport | :white_check_mark: |
| 2 | The name of the player to teleport to | :white_check_mark: |

| Examples |
|---|
| `!teleport me Eldor` |
| `!teleport Eldor me` |
| `!teleport Eldor Rektinator` |

| Permission level |
|---|
| 2 |

## chat_command_text_help.gsc

Prints how to use the `commands` and the `help command` commands in the player's chat.

| Example |
|---|
| `!help` |

| Permission level |
|---|
| 1 |

## chat_command_text_rules.gsc

Prints the server rules in the player's chat.  

| Example |
|---|
| `!rules` |

| Permission level |
|---|
| 1 |

## chat_command_unfair_aimbot.gsc

Toggles unfair aimbot on the targeted player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle unfair aimbot for | :white_check_mark: |

| Examples |
|---|
| `!unfairaimbot me` |
| `!unfairaimbot Resxt` |

| Permission level |
|---|
| 4 |

## chat_command_unlimited_ammo.gsc

Toggles unlimited ammo on the targeted player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle unlimited ammo for | :white_check_mark: |

| Examples |
|---|
| `!unlimitedammo me` |
| `!unlimitedammo Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_wallhack.gsc

Toggles wallhack (red boxes) on the targeted player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle wallhack for | :white_check_mark: |

| Examples |
|---|
| `!wallhack me` |
| `!wallhack Resxt` |

| Permission level |
|---|
| 4 |
