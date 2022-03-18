Init()
{
    level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
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
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");

	//Debug(current_weapon);
	
	if (current_weapon == "iw5_rsass_mp_rsassscope")
	{
		ReplaceWeapon("iw5_cheytac_mp_acog");
		GiveLethalAndTactical();
		
	}
	else if (current_weapon == "iw5_rsass_mp_rsassscope_silencer03")
	{
		ReplaceWeapon("iw5_cheytac_mp_acog_silencer03");
		GiveLethalAndTactical();
	}
}

ReplaceWeapon(new_weapon)
{
	self TakeAllWeapons();
	self GiveWeapon(new_weapon);
	self SetSpawnWeapon(new_weapon); // This gives the weapon without playing the animation
}

// TakeAllWeapons() removes lethal and tactical as well so we give default items after calling it
GiveLethalAndTactical()
{
	self GiveWeapon("throwingknife_mp"); // Found in dsr files
	self GiveWeapon("flare_mp"); // Tactical insertion - found in common_mp.ff
}

// Prints text in the bootstrapper
Debug(text)
{
    Print(text);
}