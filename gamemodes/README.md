# Gamemodes

## all_or_nothing.gsc
Recreation of the Modern Warfare 3 All or Nothing gamemode based on [the wiki](https://callofduty.fandom.com/wiki/All_or_Nothing_(Game_Mode)#Call_of_Duty:_Modern_Warfare_3).  
Sadly the scavenger killstreak doesn't work for bots since for some reason the `giveLoadout()` function in `ReplaceKillstreaks()` causes an infinite loop that crashes the game