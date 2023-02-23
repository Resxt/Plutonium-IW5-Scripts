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
- All commands that require a target work with `me`. Also it doesn't matter how you type the player's name as long as you type the full name.
- Configurable command prefix. Set to `!` by default
- A plugin system to easily allow adding/removing commands. Each command has its own GSC file to easily add/remove/review/configure your commands. This also makes contributing by creating a PR to add a command a lot easier

:no_entry_sign: Features not available/to add

- Commands aliases
- Permissions/ranks to restrict some commands to a certain type of players (admin, VIP etc.)
- Support for more target aliases such as "all", "bots" and "humans"
- Configurable text colors/accent. As of now the majority of the text will be white

## chat_command_change_team.gsc

The player affected by the command dies and swaps to the other team.  

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to swap to the other team | :white_check_mark: |

| Examples |
|---|
| `!changeteam me` |
| `!changeteam Resxt` |

## chat_command_dvars.gsc

3 related commands in one file:  

- Print server dvar
- Change server dvar
- Change client dvar

| Name | Description | Arguments expected | Example |
|---|---|---|---|
| getdvar | Prints the (server) dvar value in the player's chat | (1) the dvar name | `!getdvar g_speed` |
| setdvar | Changes a dvar on the server | (1) the dvar name (2) the new dvar value | `!setdvar jump_height 500` |
| setclientdvar | Changes a dvar on the targeted player | (1) the name of the player (2) the dvar name (3) the new dvar value | `!setclientdvar Resxt cg_thirdperson 1` |

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

## chat_command_give.gsc

3 related commands in one file:  

- Give weapon
- Give killstreak
- Give camo

| Name | Description | Arguments expected | Example |
|---|---|---|---|
| giveweapon | Gives the specified weapon to the targeted player. Removes the current weapon and plays the switch animation by default | (1) the name of the targeted player (2) the weapon code name (attachments and camos accepted too) | `!giveweapon me iw5_acr_mp_reflex_camo11` |
| givekillstreak | Gives the specified killstreak to the targeted player | (1) the name of the targeted player (2) the killstreak code name | `!givekillstreak me predator_missile` |
| givecamo | Changes the camo of all the primary weapons the targeted player has to the specified camo. Plays the switch animation by default | (1) the name of the targeted player (2) the name of the camo or its index | `!givecamo me gold` |

You can check [this](https://www.itsmods.com/forum/Thread-Tutorial-MW3-weapons-perks-camos-attachments.html) to get weapon/killstreak/camos names.  

Note that for weapons you need to add `_mp` at the end of the weapon name.  
So for example if the website says `iw5_scar` you would replace it with `iw5_scar_mp`.  
This is only for the weapon name, if you add an attachment and/or a camo `mp` would still be at the same position, it wouldn't be at the end.  
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

## chat_command_kill.gsc

The player who runs the command kills the targeted player (no matter if they're in the same team or not)

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to kill | :white_check_mark: |

| Examples |
|---|
| `!kill me` |
| `!kill Resxt` |

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

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle norecoil for | :white_check_mark: |

| Examples |
|---|
| `!norecoil me` |
| `!norecoil Resxt` |

## chat_command_suicide.gsc

The player who runs the command dies.  

| Example |
|---|
| `!suicide` |

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

## chat_command_text_help.gsc

Prints how to use the `commands` and the `help command` commands in the player's chat.

| Example |
|---|
| `!help` |

## chat_command_text_rules.gsc

Prints the server rules in the player's chat.  

| Example |
|---|
| `!rules` |

## chat_command_unfair_aimbot.gsc

Toggles unfair aimbot on the targeted player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle unlimited ammo for | :white_check_mark: |

| Examples |
|---|
| `!unfairaimbot me` |
| `!unfairaimbot Resxt` |

## chat_command_unlimited_ammo.gsc

Toggles unlimited ammo on the targeted player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle unlimited ammo for | :white_check_mark: |

| Examples |
|---|
| `!unlimitedammo me` |
| `!unlimitedammo Resxt` |

## chat_command_wallhack.gsc

Toggles wallhack (red boxes) on the targeted player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle wallhack for | :white_check_mark: |

| Examples |
|---|
| `!wallhack me` |
| `!wallhack Resxt` |

## chat_commands.gsc

The core script that holds the configuration, runs all the chat logic and holds utils function that are shared between all the `chat_command` scripts.
