# Disable Self Explosive Damage

Prevents players from dying to their own grenades and rockets.
Note that if you shoot enough rockets (around 15/20) you can still kill yourself.
This also doesn't prevent players from killing themselves when they hold a frag grenade in their hands.

You can add `iprintlnbold(iDamage);` at the beginning of `cancelDamage()` or any other variable found in `cancelDamage()` to debug it (see attacked player, attacker, damage, weapon used, damage type etc.)