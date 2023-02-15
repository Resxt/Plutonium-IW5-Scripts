# Gamemodes

## all_or_nothing.gsc

Recreation of the Modern Warfare 3 All or Nothing gamemode based on [the wiki](https://callofduty.fandom.com/wiki/All_or_Nothing_(Game_Mode)#Call_of_Duty:_Modern_Warfare_3).  
The bots won't use their throwing knives often and when they do they will use preset grenade spots, they won't directly aim at a player.

## chaos.gsc

A custom modded mode I created that's pretty much.. chaos. The best way to understand what it is to try it with bots.  
It's a mode with high jump and high speed where everyone has a weapon that shoots explosive projectiles such as AC-130, Stinger or RPG rockets and so on.  
Every 25 kills you get a new weapon with a new explosive to shoot. It's made so that every time you progress you get a weapon that shoots slower and has less bullets but your projecticles cause bigger explosions.  
Every game the weapons and explosives are randomized from the list but every player has the same progression, just like a gun game.  

I recommend playing this on [custom maps](https://forum.plutonium.pw/category/27/mw3-modding-releases-resources) that have no/less invisible walls.  
In my experience most COD 4 maps don't have a lot of invisible walls so you can jump and bunny hop everywhere on the map.  
You might also want to configure the script and your game further, for example by lowering the health to avoid hitmarkers.  
I recommend using my [jump_monitor](https://github.com/Resxt/Plutonium-IW5-Scripts/tree/main/small_scripts#jump_monitorgsc) script with this gamemode, it was made to be used with this.

This was made for FFA/Deathmatch. Some modifications are necessary to get it working in other modes.  
Bot Warfare bots are supported but the code for it is disabled by default to avoid getting any error in case Bot Warfare isn't installed.  
To enable support for Bot Warfare simply uncomment the lines where it says `Uncomment if using Bot Warfare`.

## gun_game.gsc

Recreation of the popular gun game mode with a good level of customization.  
This was made for FFA/Deathmatch. Some modifications are necessary to get it working in other modes.  

Bot Warfare bots are supported but the code for it is disabled by default to avoid getting any error in case Bot Warfare isn't installed.  
To enable support for Bot Warfare simply uncomment the lines where it says `Uncomment if using Bot Warfare`.

:white_check_mark: Features available

- Configure the amount of weapons per game
- Configure how much chance there is weapons will have a scope attachment
- Configure how much chance there is snipers and shotguns will use the default scope
- Configure how much chance there is a secondary weapon will be akimbo or have a tactical knife
- Configure how much chance there is weapons will have a classic attachment (silencer, heartbeat etc.)
- Configure the percentage of primary weapons to have
- Configure whether you only want primary weapons or secondary weapons only or both
- Configure which categories you don't want (for example accept secondaries but not launchers)
- Configure the uniqueness of weapons. Choose between unique weapons (cannot have the same weapon twice) or weapon + attachments combination (you can have the same weapon but a weapon cannot have the exact same attachment combination twice) or no uniqueness check at all, truly random
- Configure which camos are randomized on the weapons (or have one to always have that camo)
- Configure which attachments are banned globally, per weapon type or per weapon (I banned the attachments that don't exist and the silencer on shotguns by default)
- Akimbo and tactical secondaries with attachments (silencer, scopes etc.)
- Text to display the current player's weapon
- Prevent multi kills from counting as multi kills. A double kill will only make the player go up by one weapon and his score will only go up by 50.
- Play the gun game next weapon sound when the player gets the next weapon and play a sound to all players when a player reaches the last weapon
- Choose which perks to give to the players
- A configurable debug mode to print the array of weapons and also switch weapons when typing in the chat

:no_entry_sign: Features not available/to add

- Use dvars instead of GSC arrays
- Configure the weight of each weapon type
- Only FFA is supported. Support for some game modes like TDM and Infected could be adde
- These attachments aren't supported: grenade launcher, shotgun, variable scope.  
They weren't even tested so if you add them you will need to do some debug
- The stinger isn't supported. A GSC script from another source could give support for player lock-on
- There is no unexpected cases/exceptions handling. For example if you ask for 60 weapons and only want a weapon one time this will create an infinite loop because there are only 51 weapons available
- Some weapons like the AC-130 could be added in a special category later

## kamikaze.gsc

A custom modded mode I created that's really simple. The best way to understand what it is to try it with friends (or bots).  
It's a mode with high jump and high speed where everyone has a C4 detonator and needs to run close enough to other players to detonate it and get kills.  
Every 5 kills your explosion radius slightly increases and every 15 kills the cooldown between each detonation you can do is lowered.

This mode could also work really well without high jump and high speed, it's just how I created it to make it a "modded" mode.  
If you play it with high jump/speed I recommend playing this on [custom maps](https://forum.plutonium.pw/category/27/mw3-modding-releases-resources) that have no/less invisible walls.  
In my experience most COD 4 maps don't have a lot of invisible walls so you can jump and bunny hop everywhere on the map.  
I recommend using my [jump_monitor](https://github.com/Resxt/Plutonium-IW5-Scripts/tree/main/small_scripts#jump_monitorgsc) script with this gamemode, it was made to be used with this.

This was made for FFA/Deathmatch. Some modifications are necessary to get it working in other modes.  
Bot Warfare bots are supported but the code for it is disabled by default to avoid getting any error in case Bot Warfare isn't installed.  
To enable support for Bot Warfare simply uncomment the lines where it says `Uncomment if using Bot Warfare`.

## one_in_the_chamber.gsc

Recreation of the Modern Warfare 3 One In The Chamber gamemode with infinite lives.  
Each game the script will randomly choose a weapon category from the 4 available and pick a random weapon from that category but you can easily change that behavior and add/remove categories and weapons.  
Only FFA is supported, other modes require some modifications to work properly.  
Also unlike the original mode this one has infinite lives so if you want limited lives you'll need to edit the script.
