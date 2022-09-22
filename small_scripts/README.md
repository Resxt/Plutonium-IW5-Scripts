# Small scripts

Simple drag and drop scripts

## change_team_names.gsc

Change the team names to custom names depending on the game mode

## chat_commands.gsc

Let players execute commands by typing in the chat.  
This can be used to display text to the player, for example the server rules or execute GSC code to kill the player or give him a particular weapon for example.  
Since there is no permission check I would recommend deleting the sensitive commands if you run a public server or don't fully trust the people in your private match.  

This has been created for private matches and servers that don't use IW4MAdmin (or that removed its commands).  
If you plan on using this with IW4MAdmin's commands enabled you should double check that commands don't overwrite something (or remove them in IW4MAdmin)

:white_check_mark: Features available

- Easy per server (port) commands configuration
- Easy text print and functions support
- Exceptions handled with error messages (not enough arguments, command doesn't exist etc.)

:no_entry_sign: Features not available/to add

- Configure global/all servers commands

## disable_damages.gsc

Disable melee knifing damage.  
Also prevents players from dying to their own grenades and rockets.  
Note that if you shoot enough rockets (around 20/30) you can still kill yourself.  
This also doesn't prevent players from killing themselves when they hold a frag grenade in their hands.

## disable_nuke_killstreak.gsc

Prevent players from obtaining the nuke/M.O.A.B killstreak when they have enough kills.

## display_player_stats.gsc

Display the player's killstreak, total kills and deaths on top of the screen
<details>
  <summary>Image</summary>
  
  ![image](images/display_player_stats.png)
</details>

## get_player_guid.gsc

Print the GUID of a player in the console whenever he connects and whenever he chooses/changes class.

## give_perks_on_spawn.gsc

Gives perks to a player whenever he spawns if he doesn't already have them.  
This script has been written to give sleight of hand and quickdraw even if you have other perks like overkill (carry two primary weapons).  
You can find the list of perks and pro perks in [perktable.csv](https://github.com/chxseh/MW3-GSC-Dump/blob/e9445976df9f91451fa6e5dc3cb4663390aafcec/_raw-files/mp/perktable.csv)

## hardcore_tweaks.gsc

The hardcore mode replaces some game functionalities like enabling friendly fire or disabling killcams.  
With this script you can override the tweaks the hardcore mode brings.

## kill_players_under_map.gsc

This is a script that kills players when they are under the map.  
Some maps don't have a script to kill players under the map and they can exploit it to kill players while being under the map.  
Go under the map on the barrier and check the console to get the value to check.  
Then open the in-game console and type `mapname` to get the map name.  
Finally simply add a case to the `switch (map_name)` with the `mapname` value as the case and the `self.origin[2]` value as the returned value.

## kill_stuck_bots.gsc

This is a temporary solution to inactive bots or bots stuck in corners on custom maps.  
This checks for bots kills and deaths every 30 seconds. If they didn't do any kill or didn't die in 30 seconds they're considered inactive/stuck and they're killed.  
Obviously a better way to do this would be checking for their positions or removing bad spawns on the map or creating waypoints for the map.  
This is just a quick temporary solution that works for me.

## manage_bots_fill.gsc

Simple script that changes the Bot Warfare `bots_manage_fill` dvar dynamically to avoid using resource for an empty server.  
Whenever a player connects or disconnects the script checks the amount of human players and the value of `bots_manage_fill` and sets it accordingly.  
If the first player joins, it sets the dvar to the value you configured for that specific server (set in `InitServersDvar()` with the server port).  
If the last player leaves it sets back the dvar to 0 so that no bots will be playing, saving some resources on that server.

## remove_heavy_weapon_slow.gsc

Set back your speed scale to default whenever you have an heavy weapon equipped.  
Whenever you have an LMG gun or heavy sniper like a Barrett your speed will be slower than with most weapons.  
This script makes it so that no matter the weapons you have in your class your speed will be normal/default.  
The script doesn't modify the player's speed, instead it modifies the speed scaling (sets it back to 1) so it's safe to use with modified `g_speed`.  
The speeds were tested/monitored with this [speed meter script from quaK](https://github.com/Joelrau/IW5p_DeathRun/blob/aaa9a4231d338b765d8b0fc8b06825b3a6d2a413/plugins/simplevelometer.gsc)

## show_text_on_first_spawn.gsc

Display a text to a player when it's the first time he spawns in a match.  
This can be used to display a specific rule, a warning or just a message.
