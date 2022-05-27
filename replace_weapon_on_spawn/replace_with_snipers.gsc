#include common_scripts\utility;

Init()
{
    level.rws_available_weapons = [];
    level.rws_available_weapons[level.rws_available_weapons.size] = "iw5_l96a1_mp_l96a1scope_xmags";
    level.rws_available_weapons[level.rws_available_weapons.size] = "iw5_msr_mp_msrscope_xmags";
    level.rws_available_weapons[level.rws_available_weapons.size] = "iw5_cheytac_mp_cheytacscope_xmags";

    level.rws_applies_to = 0; // 0 = bots only, 1 = players only, 2 = everyone

    level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);

        if (isDefined(player.pers["isBot"]))
        {
            if (player.pers["isBot"])
            {
                if (level.rws_applies_to == 1) {
                    continue; // if level.rws_applies_to is set to players only and we are a bot, skip
                }
            }
            else {
                if (level.rws_applies_to == 0) {
                    continue; // if level.rws_applies_to is set to bots only and we are a player, skip
                }
            }
        }
        else {
            if (level.rws_applies_to == 0) {
                continue; // if level.rws_applies_to is set to bots only and we are a player, skip
            }
        }

        player thread OnPlayerSpawned();
    }
}

OnPlayerSpawned()
{
	self endon("disconnect");

    for(;;)
    {
		self waittill("changed_kit");

		current_weapon = self GetCurrentWeapon();

		self thread DoWeaponCheck(current_weapon);
	}
}

DoWeaponCheck(current_weapon)
{
    // Uncomment this block and put all the code below (in this function) in the if condition if you don't want to change classes that already have the correct primary
    // Additional checks are required to check for secondary weapon lethal/tactical grenades
    // Thanks to TakeAllWeapons() in ReplaceWeapon() the secondary weapon and lethal/tactical grenades are removed so no check is needed
    
    /*weapon_tokens = strTok(current_weapon, "_");

    if (weapon_tokens[1] != "l96a1" && weapon_tokens[1] != "msr" && weapon_tokens[1] != "cheytac") {
        
    }*/

    ReplaceWeapon(random(level.rws_available_weapons));
}

ReplaceWeapon(new_weapon)
{
	self TakeAllWeapons();
	self GiveWeapon(new_weapon);
	self SetSpawnWeapon(new_weapon); // This gives the weapon without playing the animation
}