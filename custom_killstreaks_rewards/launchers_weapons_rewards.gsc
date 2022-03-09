#include maps\mp\_utility;

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
	level thread OnPlayerConnect();
	level.killstreakSpawnShield = 0; // Disable anti killstreak protection on player spawn
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

		print(self.name);

		if (isDefined(self.pers["isBot"]))
		{
			if (self.pers["isBot"])
			{
				return;
			}
		}
		
		self thread WeaponReward();
	}
}

ReplaceWeapon(new_weapon)
{
	self TakeAllWeapons();
	self GiveWeapon(new_weapon);
	self GiveWeapon("semtex_mp"); // Found in dsr files
	self GiveWeapon("flare_mp"); // Tactical insertion - found in common_mp.ff
	self SetSpawnWeapon(new_weapon); // This gives the weapon without playing the animation
}

WeaponReward()
{
	self endon ("disconnect");
	level endon("game_ended");

	spawn_weapon = self GetCurrentWeapon();

	while(true)
	{
		weapon_rewards = [[5, "m320_mp"], [10, "rpg_mp"], [15, "ac130_40mm_mp"], [25, "ac130_105mm_mp"], [35, spawn_weapon]]; // [kills_required, weapon_reward]
		CheckWeaponReward(weapon_rewards);
		wait 0.01;
	}
}

CheckWeaponReward(weapon_rewards)
{
	current_kill_streak = self.pers["cur_kill_streak"];

	// Whenever a player got all the rewards we force current_kill_streak to still be synchronized with weapon_rewards kills requirements.
	// If our last weapon_rewards kill requirement is 35 and current_kill_streak is 36 then current_kill_streak will be changed to 1 (so at 40 kills we'll get the reward for 5 kills again and so on)
	last_reward_kills = weapon_rewards[weapon_rewards.size-1][0];
	if (current_kill_streak > last_reward_kills)
	{
		current_kill_streak = current_kill_streak - (last_reward_kills * floor(current_kill_streak / last_reward_kills)) + 1;
	}

	for (i = 0; i < weapon_rewards.size; i++)
	{
		next_reward = weapon_rewards[i][1];
		if (current_kill_streak >= weapon_rewards[i][0] && current_kill_streak < weapon_rewards[i+1][0] && self GetCurrentWeapon() != next_reward)
		{
			ReplaceWeapon(next_reward);
			break;
		}
	}
}

// Allow the AC-130 kills to be counted in player.pers["cur_kill_streak"]
WhitelistKillstreaksInKillsCount( weapon )
{	
	if ( self _hasPerk( "specialty_explosivebullets" ) )	
		return false;	
		
	if ( IsDefined( self.isJuggernautRecon ) && self.isJuggernautRecon == true )
		return false;

	if (weapon == "ac130_40mm_mp")
		return true;

	if (weapon == "ac130_105mm_mp")
		return true;
		
	if ( IsDefined( level.killstreakChainingWeapons[weapon] ) )	
	{
		for( i = KILLSTREAK_SLOT_1; i < KILLSTREAK_SLOT_3 + 1; i++ )
		{
			// only if it was earned this life
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