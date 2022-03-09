# Custom Killstreak Rewards

Scripts that give the players different weapons or perks depending on their current killstreak or total kills count

## launchers_weapons_rewards.gsc

Gives the player a new weapon every time he reaches a new tier.  
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