#include maps\mp\_utility;

// This is required by killShouldAddToKillstreak()
KILLSTREAK_GIMME_SLOT = 0;
KILLSTREAK_SLOT_1 = 1;
KILLSTREAK_SLOT_2 = 2;
KILLSTREAK_SLOT_3 = 3;
KILLSTREAK_ALL_PERKS_SLOT = 4;
KILLSTREAK_STACKING_START_SLOT = 5;

Main()
{
	replacefunc(maps\mp\_utility::killShouldAddToKillstreak, ::WhitelistKillstreaksInKillsCount);
}

Init()
{
	kills_limit = 80; // Override score limit (required to make the script sync with how much kills is the limit)
	time_limit = 10; // Override time limit (optional, see SetLimits() reference)
	weapon_switch_kills = 10; // Every weapon_switch_kills the player's weapon will change (this is total kills, not killstreak)

	// Note that if you want to let bots earn rewards you need to disable custom classes or remove/change the WeaponIsValid() check in WeaponReward()
	level.bots_earn_rewards = true;
	// Create a class with the weapon and attachements you want and uncomment the Debug() line in OnPlayerSpawned() to get the full weapon name with attachments when you spawn
	level.available_weapon_rewards = [
		"iw5_m4_mp_reflex_silencer", 
		"iw5_scar_mp_reflex_silencer", 
		"iw5_cm901_mp_reflex_silencer", 
		"iw5_g36c_mp_reflex_silencer", 
		"iw5_acr_mp_reflex_silencer", 
		"iw5_ak47_mp_reflex_silencer",
		"iw5_fad_mp_reflex_silencer",
		"iw5_mp5_mp_reflexsmg_silencer",
		"iw5_ump45_mp_reflexsmg_silencer",
		"iw5_pp90m1_mp_reflexsmg_silencer",
		"iw5_p90_mp_reflexsmg_silencer",
		"iw5_m9_mp_reflexsmg_silencer",
		"iw5_mp7_mp_reflexsmg_silencer",
		"iw5_ak74u_mp_reflexsmg_silencer",
		"iw5_sa80_mp_reflexlmg_silencer",
		"iw5_mg36_mp_reflexlmg_silencer",
		"iw5_pecheneg_mp_reflexlmg_silencer",
		"iw5_mk46_mp_reflexlmg_silencer",
		"iw5_m60_mp_reflexlmg_silencer",
		"iw5_dragunov_mp_acog_silencer03",
		"iw5_rsass_mp_acog_silencer03"
	];

	level.killstreakSpawnShield = 0; // Disable anti killstreak protection on player spawn
	level.weapon_rewards = [];

	SetLimits(kills_limit, time_limit);
	InitWeaponRewards(kills_limit, weapon_switch_kills, "ac130_25mm_mp");

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
		self waittill("spawned_player");

		if (!level.bots_earn_rewards)
		{
			if (isDefined(self.pers["isBot"]))
			{
				if (self.pers["isBot"])
				{
					return;
				}
			}
		}

		// Debug(self GetCurrentWeapon());
		
		self thread WeaponReward();
	}
}

// time_limit is optional
SetLimits(kills_limit, time_limit)
{
	score_multiplier = 0;

	switch (level.gameType)
	{
		case "dm":
			score_multiplier = 50;
			break;
		case "war":
			score_multiplier = 100;
			break;
		default:
			score_multiplier = 50;
			break;
	}

    SetDvar("scr_" + level.gameType + "_scorelimit", kills_limit * score_multiplier);
	SetDvar("scorelimit", kills_limit * score_multiplier);

	if (time_limit != undefined)
	{
		SetDvar("scr_" + level.gameType + "_timelimit", time_limit);
		SetDvar("timelimit", time_limit);
	}
}

// The third parameter is optional. Without this parameter all weapons will be random. With a weapon passed as third parameter the last weapon will be the weapon of your choice
InitWeaponRewards(kills_limit, weapon_switch_kills, last_weapon)
{
	condition = kills_limit;
	if (last_weapon != undefined)
	{
		condition = kills_limit - weapon_switch_kills;
	}

	for (i = 0; i < condition; i = i + weapon_switch_kills)
	{
		is_unique = false;
		
		while (!is_unique)
		{
			random_weapon = GetRandomElementFromArray(level.available_weapon_rewards);

			weapon_already_exist = false;

			foreach (value in level.weapon_rewards)
			{
				if (value[1] == random_weapon)
				{
					weapon_already_exist = true;
					break;
				}
			}

			// If we already gave all the available weapons force the unique check to false so that we can keep giving weapons
			if (level.weapon_rewards.size >= level.available_weapon_rewards.size)
			{
				weapon_already_exist = false;
			}

			if (weapon_already_exist)
			{
				weapon_already_exist = false;
			}
			else
			{
				is_unique = true;
				level.weapon_rewards[level.weapon_rewards.size] = [i, random_weapon];
			}
		}
	}

	if (last_weapon != undefined)
	{
		level.weapon_rewards[level.weapon_rewards.size] = [kills_limit - weapon_switch_kills, last_weapon];

		// Because CheckWeaponReward() always excepts a next element we have to add a fake element so that the last element can still be compared with something, ignore this
		level.weapon_rewards[level.weapon_rewards.size] = [kills_limit, last_weapon];
	}
	else
	{
		// Because CheckWeaponReward() always excepts a next element we have to add a fake element so that the last element can still be compared with something, ignore this
		level.weapon_rewards[level.weapon_rewards.size] = [kills_limit, "none"];
	}
}

WeaponReward()
{
	self endon ("disconnect");
	level endon("game_ended");

	spawn_weapon = self GetCurrentWeapon();

	if (WeaponIsValid(spawn_weapon))
	{
		while(true)
		{
			CheckWeaponReward(level.weapon_rewards);
			wait 0.01;
		}
	}
}

CheckWeaponReward(weapon_rewards)
{
	player_kills = self.pers["kills"];

	for (i = 0; i < weapon_rewards.size; i++)
	{
		next_reward = weapon_rewards[i][1];
		if (player_kills >= weapon_rewards[i][0] && player_kills < weapon_rewards[i+1][0] && self GetCurrentWeapon() != next_reward)
		{
			ReplaceWeapon(next_reward);
			break;
		}
	}
}

ReplaceWeapon(new_weapon)
{
	self TakeAllWeapons();
	self GiveWeapon(new_weapon);
	self GiveWeapon("flare_mp"); // Tactical insertion - weapon_already_exist in common_mp.ff
	self SetSpawnWeapon(new_weapon); // This gives the weapon without playing the animation
}

WeaponIsValid(weapon)
{
	switch (weapon)
	{
		case "iw5_m4_mp_shotgun_thermal":
			return true;
		default:
			return false;
	}
}

GetRandomElementFromArray( array )
{
	new_array = [];
	foreach ( index, value in array )
	{
		new_array[ new_array.size ] = value;
	}

	if ( !new_array.size )
		return undefined;
	
	return new_array[ randomint( new_array.size ) ];
}

// Allow the AC-130 kills to be counted in player.pers["cur_kill_streak"]
WhitelistKillstreaksInKillsCount( weapon )
{	
	if ( self _hasPerk( "specialty_explosivebullets" ) )	
		return false;	
		
	if ( IsDefined( self.isJuggernautRecon ) && self.isJuggernautRecon == true )
		return false;

	if (weapon == "ac130_25mm_mp")
		return true;
		
	if ( IsDefined( level.killstreakChainingWeapons[weapon] ) )	
	{
		for( i = KILLSTREAK_SLOT_1; i < KILLSTREAK_SLOT_3 + 1; i++ )
		{
			if( IsDefined( self.pers["killstreaks"][i] ) && 
				IsDefined( self.pers["killstreaks"][i].streakName ) &&
				self.pers["killstreaks"][i].streakName == level.killstreakChainingWeapons[weapon] && 
				IsDefined( self.pers["killstreaks"][i].lifeId ) && 
				self.pers["killstreaks"][i].lifeId == self.pers["deaths"] )
			{
				return self streakShouldChain( level.killstreakChainingWeapons[weapon] );
			}
		}		
		return false;
	}
		
	return !isKillstreakWeapon( weapon );	
}

// Prints text in the bootstrapper
Debug(text)
{
    Print(text);
}