# Small scripts

Simple drag and drop scripts

## change_team_names.gsc

Change the team names to custom names depending on the game mode

## disable_self_explosive_damage.gsc

Prevents players from dying to their own grenades and rockets.  
Note that if you shoot enough rockets (around 20/30) you can still kill yourself.  
This also doesn't prevent players from killing themselves when they hold a frag grenade in their hands.

## display_player_stats.gsc

Display the player's killstreak, total kills and deaths on top of the screen
<details>
  <summary>Image</summary>
  
  ![image](images/display_player_stats.png)
</details>

## get_player_guid.gsc

Print the GUID of a player in the console whenever he connects and whenever he chooses/changes class.

## hardcore_tweaks.gsc

The hardcore mode replaces some game functionalities like enabling friendly fire or disabling killcams.  
With this script you can override the tweaks the hardcore mode brings.

## kill_stuck_bots.gsc

This is a temporary solution to inactive bots or bots stuck in corners on custom maps.  
This checks for bots kills and deaths every 30 seconds. If they didn't do any kill or didn't die in 30 seconds they're considered inactive/stuck and they're killed.  
Obviously a better way to do this would be checking for their positions or removing bad spawns on the map or creating waypoints for the map.  
This is just a quick temporary solution that works for me.

## show_text_on_first_spawn.gsc

Display a text to a player when it's the first time he spawns in a match.  
This can be used to display a specific rule, a warning or just a message.
