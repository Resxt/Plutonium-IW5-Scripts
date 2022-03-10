# Custom Killstreak Rewards

Scripts that give the players different weapons or perks depending on their current killstreak or total kills count

## launchers_weapons_rewards.gsc

Gives the player a new weapon every time he reaches a new tier.  
`WeaponIsValid()` ensures that the rewards are only given if the player's spawn weapon is a launcher.  
If the player reaches the last tier the loop restarts allowing players to get tiers several time per life if they ever get enough kills.  
For example with this script if you get 50 kills in a row you would get the AC130 105mm two times.  
This is how the script is configured

* 5 kills: M320
* 10 kills: RPG
* 15 kills: AC130 40mm
* 25 kills: AC130 105mm
* 35 kills: Spawn weapon

This script also whitelists the AC130 for the kill counts.  
This is useful to make sure kills are properly tracked on kill counters scripts.  
This also removes the killstreak protection players have after spawning.

## automatic_weapons_rewards.gsc

A re-creation of the gun game mode with a bit more configuration.
Every game the script picks random (and unique) weapons from `level.available_weapon_rewards` to populate `weapon_rewards`.
Whenever a player reaches a new tier (defined with `weapon_switch_kills`) he will get the next weapon.  

If you ask for more weapon than the max amount of available weapons then the unique check is removed when all weapons were given.  
This ensures that all weapons are unique and that if you want more weapons than the max amount available you have each weapon at least once.

`InitWeaponRewards()` allow you to have random weapons only or to hard code the last weapon in your games.
You can also enable or disable `bots_earn_rewards` to change whether bots can earn weapons too.  

Because this is based around the server's kill limit and the player's current total kills this only works on kill based game modes (FFA, TDM etc.)  
If you want to use this on objective based game modes you will have to read the script and make some modifications.  

By default the script sets the score limit to 80 kills and the time limit to 10 minutes and gives you a new weapon every 10 kills.  
Whenever you reach 70 kills it will always give you the `ac130_25mm_mp` weapon.