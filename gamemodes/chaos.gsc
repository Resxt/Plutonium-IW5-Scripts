/*
======================================================================
|                         Game: Plutonium IW5 	                     |
|                   Description : Chaos custom mode                  |
|                            Author: Resxt                           |
======================================================================
| https://github.com/Resxt/Plutonium-IW5-Scripts/tree/main/gamemodes |
======================================================================
*/

#include maps\mp\_utility;
#include maps\mp\gametypes\_class;
//#include maps\mp\bots\_bot_utility; // Uncomment if using Bot Warfare

/* Entry point */

Init()
{
    InitChaos();
}



/* Init section */ 

InitChaos()
{
    replacefunc(maps\mp\_utility::allowClassChoice, ::ReplaceAllowClassChoice);
    replacefunc(maps\mp\_utility::allowTeamChoice, ::ReplaceAllowTeamChoice);
    replacefunc(maps\mp\_utility::killShouldAddToKillstreak, ::ReplaceKillShouldAddToKillstreak);

    level.killstreakSpawnShield = 0; // Disable anti killstreak protection on player spawn
    level.callbackplayerdamagestub = level.callbackplayerdamage;
    level.callbackplayerdamage = ::ChaosDamages; // Disable direct bullet hit damage and self damage (explosions)

    InitConfigVariables();
    InitGameVariables();
    
    SetGameLimits(level.chaos_kills_limit, (level.chaos_kills_limit / 5));

    SetDvar("player_sustainAmmo", 0);
    SetDvar("jump_height", 585);
    SetDvar("g_speed", 475);
    SetDvar("g_gravity", 400);
    SetDvar("g_playerCollision", 2);
    SetDvar("g_playerEjection", 2);
    SetDvar("jump_autoBunnyHop", 1);
    SetDvar("jump_disableFallDamage", 1);
    SetDvar("jump_slowdownEnable", 0);
    SetDvar("jump_spreadAdd", 0);

    level thread OnPlayerConnect();
}

InitConfigVariables()
{
    level.chaos_kills_limit = 125;
    
    level.chaos_config_levels[0]["weapons"] = ["iw5_cm901_mp", "iw5_cm901_mp_silencer", "iw5_mk14_mp", "iw5_mk14_mp_silencer", "iw5_ak47_mp", "iw5_ak47_mp_silencer", "iw5_ump45_mp", "iw5_ump45_mp_silencer", "iw5_mp9_mp", "iw5_mp9_mp_silencer02"];
    level.chaos_config_levels[0]["bullets"] = ["ac130_40mm_mp", "ims_projectile_mp"];
    level.chaos_config_levels[25]["weapons"] = ["iw5_dragunov_mp", "iw5_dragunov_mp_silencer03", "iw5_dragunov_mp_acog", "iw5_dragunov_mp_acog_silencer03", "iw5_rsass_mp", "iw5_rsass_mp_silencer03", "iw5_rsass_mp_acog", "iw5_rsass_mp_acog_silencer03", "iw5_usas12_mp", "iw5_usas12_mp_silencer03", "iw5_usas12_mp_reflex", "iw5_usas12_mp_reflex_silencer03"];
    level.chaos_config_levels[25]["bullets"] = ["m320_mp", "rpg_mp", "remote_mortar_missile_mp"];
    level.chaos_config_levels[50]["weapons"] = ["iw5_44magnum_mp", "iw5_usp45_mp", "iw5_deserteagle_mp", "iw5_mp412_mp", "iw5_p99_mp", "iw5_fnfiveseven_mp", "iw5_44magnum_mp_silencer02", "iw5_usp45_mp_silencer02", "iw5_deserteagle_mp_silencer02", "iw5_mp412_mp_silencer02", "iw5_p99_mp_silencer02", "iw5_fnfiveseven_mp_silencer02", "iw5_44magnum_mp_akimbo", "iw5_usp45_mp_akimbo", "iw5_deserteagle_mp_akimbo", "iw5_mp412_mp_akimbo", "iw5_p99_mp_akimbo", "iw5_fnfiveseven_mp_akimbo", "iw5_44magnum_mp_akimbo_silencer02", "iw5_usp45_mp_akimbo_silencer02", "iw5_deserteagle_mp_akimbo_silencer02", "iw5_mp412_mp_akimbo_silencer02", "iw5_p99_mp_akimbo_silencer02", "iw5_fnfiveseven_mp_akimbo_silencer02"];
    level.chaos_config_levels[50]["bullets"] = ["stinger_mp"];
    level.chaos_config_levels[75]["weapons"] = ["iw5_l96a1_mp", "iw5_msr_mp", "iw5_cheytac_mp", "iw5_l96a1_mp_silencer03", "iw5_msr_mp_silencer03", "iw5_cheytac_mp_silencer03", "iw5_l96a1_mp_acog", "iw5_msr_mp_acog", "iw5_cheytac_mp_acog", "iw5_l96a1_mp_acog_silencer03", "iw5_msr_mp_acog_silencer03", "iw5_cheytac_mp_acog_silencer03"];
    level.chaos_config_levels[75]["bullets"] = ["ac130_105mm_mp", "javelin_mp"];
    level.chaos_config_levels[100]["weapons"] = ["iw5_ksg_mp", "iw5_spas12_mp", "iw5_striker_mp", "iw5_1887_mp"];
    level.chaos_config_levels[100]["bullets"] = ["uav_strike_projectile_mp"];
}

InitGameVariables()
{
    foreach (key in GetArrayKeys(level.chaos_config_levels))
    {
        level.chaos_levels[key]["weapon"] = GetRandomElementInArray(level.chaos_config_levels[key]["weapons"]);
        level.chaos_levels[key]["bullet"] = GetRandomElementInArray(level.chaos_config_levels[key]["bullets"]);
    }
}



/* Player section */

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);

        player.pers["chaos_level"] = 0;
        player.pers["last_registered_kills"] = 0;

        player thread OnPlayerSpawned();
        player thread OnPlayerKill();
        player thread OnPlayerReload();
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("spawned_player");

        self GivePlayerEquipment();

        Print(self.pers["clientData"]);
        Print(self.pers["clientData"].permissionLevel);
    }
}

OnPlayerKill()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill( "killed_enemy" );

        killsForNewWeapon = self.pers["chaos_level"] + 25;

        if (self.pers["last_registered_kills"] < killsForNewWeapon && self.kills >= killsForNewWeapon && killsForNewWeapon != level.chaos_kills_limit)
        {
            self.pers["chaos_level"] = killsForNewWeapon;

            self notify("chaos_level_up");

            self GivePlayerEquipment();
        }
    }
}

OnPlayerReload()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "reload" );

        self GiveMaxAmmo(self GetCurrentWeapon());
    }
}

ClearPlayerClass()
{
    self.pers["gamemodeLoadout"] = self cloneLoadout();	
    
    self.pers["gamemodeLoadout"]["loadoutJuggernaut"] = false;
    self.pers["gamemodeLoadout"]["loadoutPrimary"] = "none";
    self.pers["gamemodeLoadout"]["loadoutSecondary"] = "none";
    self.pers["gamemodeLoadout"]["loadoutKillstreak1"] = "none";
    self.pers["gamemodeLoadout"]["loadoutKillstreak2"] = "none";
    self.pers["gamemodeLoadout"]["loadoutKillstreak3"] = "none";
    self.pers["gamemodeLoadout"]["loadoutPerk1"] = "none";
    self.pers["gamemodeLoadout"]["loadoutPerk2"] = "none";
    self.pers["gamemodeLoadout"]["loadoutPerk3"] = "none";

    if (!self IsBot())
	{
		self maps\mp\gametypes\_class::giveLoadout(self.team, "gamemode", false, true);
	}
	else
	{
        //self botGiveLoadout(self.team, "gamemode", false, true); // Uncomment if using Bot Warfare
	}

    maps\mp\killstreaks\_killstreaks::clearKillstreaks();
}

GiveChaosWeapon()
{
    self TakeAllWeapons();

    newWeapon = level.chaos_levels[self.pers["chaos_level"]]["weapon"];

    self GiveWeapon(newWeapon);
    self SwitchToWeapon(newWeapon);
    self GiveMaxAmmo(newWeapon);
    self SetSpawnWeapon(newWeapon);

    self thread GiveChaosBullets(level.chaos_levels[self.pers["chaos_level"]]["bullet"]);
}

GiveChaosBullets(bulletType)
{
self endon("death");
self endon("chaos_level_up");

for(;; )
{
self waittill( "weapon_fired" );
MagicBullet(bulletType, self getTagOrigin("tag_eye"), self GetCursorPos(), self );		  
}
}
GetCursorPos()
{
return BulletTrace( self getTagOrigin("tag_eye"), vector_scal(anglestoforward(self getPlayerAngles()),1000000), 0, self )[ "position" ];
}
vector_scal(vec, scale)
{
return (vec[0] * scale, vec[1] * scale, vec[2] * scale);
}

GiveChaosPerks()
{
    self GivePerk("specialty_longersprint", false); // Extreme conditioning
    self GivePerk(GetProPerkName("specialty_longersprint"), false); // Extreme conditioning PRO

    self GivePerk("specialty_bulletaccuracy", false); // Steady aim
    self GivePerk(GetProPerkName("specialty_bulletaccuracy"), false); // Steady aim PRO

    self GivePerk(GetProPerkName("specialty_quieter"), false); // Dead silence PRO
}

GivePlayerEquipment()
{
    self ClearPlayerClass();
    self DisableWeaponPickup();
        
    self GiveChaosWeapon();
    self GiveChaosPerks();
}



/* Utils section */

GetRandomElementInArray(array)
{
    return array[GetArrayKeys(array)[randomint(array.size)]];
}


GetProPerkName(perkName)
{
    return tablelookup( "mp/perktable.csv", 1, perkName, 8 );
}

/*
<kills_limit> the amount of kills to win
<time_limit> the amount of minutes until the game ends (optional)
Example:
SetGameLimits(20); will change the kills limit to 20
SetGameLimits(40, 15); will change the kills limit to 40 and the time limit to 15 minutes
*/
SetGameLimits(kills_limit, time_limit)
{
    score_multiplier = 0;

    switch(level.gameType)
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

    if (IsDefined(time_limit))
	{
		SetDvar("scr_" + level.gameType + "_timelimit", time_limit);
		SetDvar("timelimit", time_limit);
	}
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}



/* Replaced functions section */

ReplaceAllowClassChoice()
{
	return false;	
}

ReplaceAllowTeamChoice()
{   
    return false;
}

ReplaceKillShouldAddToKillstreak()
{
    return true;
}

ChaosDamages( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if (isDefined(eAttacker))
	{
		if (isDefined(eAttacker.guid) && isDefined(self.guid))
		{
			if (eAttacker.guid == self.guid)
			{
				iDamage = 0;
			}
			else
			{
				if (sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_PISTOL_BULLET")
				{
					iDamage = 0;
				}
			}
		}
	}
		
	self [[level.callbackplayerdamagestub]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}