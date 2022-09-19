#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_class;

Init()
{
    InitOneInTheChamber();
}

InitOneInTheChamber()
{
    InitWeaponVariables();
    InitOneShotDamages();

    randomCategoryArray = GetRandomElementInArray(level.one_in_the_chamber_available_weapons);
    level.one_in_the_chamber_weapon = GetRandomElementInArray(randomCategoryArray);
    level.one_in_the_chamber_kills = 50;
    level.blockWeaponDrops = true;

    replacefunc(maps\mp\_utility::allowTeamChoice, ::ReplaceAllowTeamChoice);
    replacefunc(maps\mp\_utility::allowClassChoice, ::ReplaceAllowClassChoice);

    SetGameLimits(level.one_in_the_chamber_kills, (level.one_in_the_chamber_kills / 5));

    level thread OnPlayerConnect();
}

InitWeaponVariables()
{
    level.one_in_the_chamber_available_weapons = [];

    level.one_in_the_chamber_available_weapons["automatics"] = ["iw5_m4_mp", "iw5_m4_mp_silencer", "iw5_scar_mp", "iw5_scar_mp_silencer", "iw5_g36c_mp", "iw5_g36c_mp_silencer", "iw5_mk14_mp", "iw5_mk14_mp_silencer", "iw5_fad_mp", "iw5_fad_mp_silencer", "iw5_mp5_mp", "iw5_mp5_mp_silencer", "iw5_ump45_mp", "iw5_ump45_mp_silencer", "iw5_pp90m1_mp", "iw5_pp90m1_mp_silencer", "iw5_p90_mp", "iw5_p90_mp_silencer", "iw5_m9_mp", "iw5_m9_mp_silencer", "iw5_mp7_mp", "iw5_mp7_mp_silencer", "iw5_ak74u_mp", "iw5_ak74u_mp_silencer"];
    level.one_in_the_chamber_available_weapons["snipers"] = ["iw5_l96a1_mp_l96a1scope", "iw5_dragunov_mp_dragunovscope", "iw5_as50_mp_as50scope", "iw5_rsass_mp_rsassscope", "iw5_msr_mp_msrscope", "iw5_cheytac_mp_cheytacscope", "iw5_l96a1_mp_l96a1scope_silencer03", "iw5_dragunov_mp_dragunovscope_silencer03", "iw5_as50_mp_as50scope_silencer03", "iw5_rsass_mp_rsassscope_silencer03", "iw5_msr_mp_msrscope_silencer03", "iw5_cheytac_mp_cheytacscope", "iw5_l96a1_mp_acog", "iw5_dragunov_mp_acog", "iw5_as50_mp_acog", "iw5_rsass_mp_acog", "iw5_msr_mp_acog", "iw5_cheytac_mp_acog", "iw5_l96a1_mp_acog_silencer03", "iw5_dragunov_mp_acog_silencer03", "iw5_as50_mp_acog_silencer03", "iw5_rsass_mp_acog_silencer03", "iw5_msr_mp_acog_silencer03", "iw5_cheytac_mp_acog_silencer03"];
    level.one_in_the_chamber_available_weapons["shotguns"] = ["iw5_usas12_mp", "iw5_ksg_mp", "iw5_spas12_mp", "iw5_aa12_mp", "iw5_striker_mp", "iw5_1887_mp"];
    level.one_in_the_chamber_available_weapons["pistols"] = ["iw5_44magnum_mp_tactical", "iw5_44magnum_mp_tactical", "iw5_usp45_mp_tactical", "iw5_usp45_mp_silencer02_tactical", "iw5_deserteagle_mp_tactical", "iw5_deserteagle_mp_tactical", "iw5_mp412_mp_tactical", "iw5_mp412_mp_tactical", "iw5_p99_mp_tactical", "iw5_p99_mp_silencer02_tactical", "iw5_fnfiveseven_mp_tactical", "iw5_fnfiveseven_mp_silencer02_tactical"];
}

InitOneShotDamages()
{
	level.callbackplayerdamagestub = level.callbackplayerdamage;
    level.callbackplayerdamage = ::OneShotDamages;
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);

        player.pers["previous_score"] = 0;

        player thread OnPlayerSpawned();
        player thread OnPlayerKill();
    }
}

OnPlayerSpawned()
{
	self endon("disconnect");

    for(;;)
    {
		self waittill("changed_kit");

        self DisableWeaponPickup();

        self thread ReplaceKillstreaks();
        self thread ReplacePerks();
        self thread ReplaceWeapons(level.one_in_the_chamber_weapon);
	}
}

OnPlayerKill()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill( "killed_enemy" );

        self setweaponammoclip(level.one_in_the_chamber_weapon, self getweaponammoclip(level.one_in_the_chamber_weapon) + int((self.score - self.pers["previous_score"]) / 50));

        self.pers["previous_score"] = self.score;
    }
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

ReplaceWeapons(new_weapon)
{
    self TakeAllWeapons();
    self GiveWeapon(new_weapon);

    self setweaponammoclip( new_weapon, 1 );
    self setweaponammostock( new_weapon, 0 );

    self SetSpawnWeapon(new_weapon);
}

ReplacePerks()
{
    self ClearPerks();

    self GivePerk("specialty_fastreload", false); // Sleight of hand
    self GivePerk(GetProPerkName("specialty_fastreload"), false); // Sleight of hand PRO
    self GivePerk("specialty_longersprint", false); // Extreme conditioning
    self GivePerk(GetProPerkName("specialty_longersprint"), false); // Extreme conditioning PRO

    self GivePerk("specialty_quickdraw", false); // Quickdraw
    self GivePerk(GetProPerkName("specialty_quickdraw"), false); // Quickdraw

    self GivePerk("specialty_bulletaccuracy", false); // Steady aim
    self GivePerk(GetProPerkName("specialty_bulletaccuracy"), false); // Steady aim PRO
    self GivePerk(GetProPerkName("specialty_quieter"), false); // Dead silence PRO

    self GivePerk("specialty_fastermelee", 0);
}

ReplaceKillstreaks()
{
    self.pers["gamemodeLoadout"] = self cloneLoadout();	
    self.pers["gamemodeLoadout"]["loadoutJuggernaut"] = false;

    self.pers["gamemodeLoadout"]["loadoutStreakType"] = "streaktype_assault"; // don't give specialist bonus
    self.pers["gamemodeLoadout"]["loadoutKillstreak1"] = "none";
    self.pers["gamemodeLoadout"]["loadoutKillstreak2"] = "none";
    self.pers["gamemodeLoadout"]["loadoutKillstreak3"] = "none";

    if (self IsBot())
	{
        self maps\mp\bots\_bot_utility::botGiveLoadout(self.team, "gamemode", false, true);
    }
    else
    {
        self maps\mp\gametypes\_class::giveLoadout(self.team, "gamemode", false, true);
    }

	maps\mp\killstreaks\_killstreaks::clearKillstreaks();
}

ReplaceAllowClassChoice()
{
    return false;
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}

GetRandomElementInArray(array)
{
    return array[GetArrayKeys(array)[randomint(array.size)]];
}

GetProPerkName(perkName)
{
    return tablelookup( "mp/perktable.csv", 1, perkName, 8 );
}

OneShotDamages( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if (isDefined(eAttacker))
	{
		if (isDefined(eAttacker.guid) && isDefined(self.guid))
		{
			if (eAttacker.guid != self.guid)
			{
				iDamage = 999;
			}
		}
	}
		
	self [[level.callbackplayerdamagestub]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

ReplaceAllowTeamChoice()
{
	gametype = getDvar("g_gametype");	
	
	if (gametype == "dm" || gametype == "oitc") return false;
	else
	{
		allowed = int( tableLookup( "mp/gametypesTable.csv", 0, level.gameType, 4 ) );
		assert( isDefined( allowed ) );
	
		return allowed;
	}
}