#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_class;

Init()
{
    SetGameLimits(20);

    SetDvar("bots_play_ads", 0);
    SetDvar("bots_play_camp", 0);
    SetDvar("bots_play_killstreak", 0);

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

        self thread ReplaceKillstreaks();
        self thread ReplacePerks();
        self thread ReplaceWeapons("iw5_usp45_mp_tactical");
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
    self GiveWeapon("throwingknife_mp");

    self setweaponammoclip( new_weapon, 0 );
    self setweaponammostock( new_weapon, 0 );

    self SetSpawnWeapon(new_weapon);
}

ReplacePerks()
{
    self ClearPerks();

    self GivePerk("specialty_fastreload", 0); // Sleight of hand
    self GivePerk("specialty_longersprint", 0);// Extreme conditioning
    self GivePerk("specialty_fastmantle", 0); // Extreme condition PRO

    self GivePerk("specialty_hardline", 0); // Hardline
    
    self GivePerk("specialty_stalker", 0); // Stalker
    self GivePerk("specialty_falldamage", 0); // Dead silence PRO
}

ReplaceKillstreaks()
{
    self.pers["gamemodeLoadout"] = self cloneLoadout();	
    self.pers["gamemodeLoadout"]["loadoutJuggernaut"] = false;
    
    self.pers["gamemodeLoadout"]["loadoutEquipment"] = "throwingknife_mp";

    self.pers["gamemodeLoadout"]["loadoutStreakType"] = "streaktype_specialist";
    self.pers["gamemodeLoadout"]["loadoutKillstreak1"] = "specialty_scavenger_ks";
    self.pers["gamemodeLoadout"]["loadoutKillstreak2"] = "none";
    self.pers["gamemodeLoadout"]["loadoutKillstreak3"] = "none";

    if (self IsBot())
	{
        //self maps\mp\bots\_bot_utility::botGiveLoadout(self.team, "gamemode", false, true); // Uncomment if using Bot Warfare
    }
    else
    {
        self maps\mp\gametypes\_class::giveLoadout(self.team, "gamemode", false, true);
    }

	maps\mp\killstreaks\_killstreaks::clearKillstreaks();
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}