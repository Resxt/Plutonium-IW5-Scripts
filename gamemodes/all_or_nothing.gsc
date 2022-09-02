#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_class;

Init()
{
    SetGameLimits();

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

SetGameLimits()
{
    kills_limit = 20;
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

ReplaceWeaponBot(new_weapon)
{
	self TakeAllWeapons();
	self GiveWeapon(new_weapon);
	self SetSpawnWeapon(new_weapon); // This gives the weapon without playing the animation
}

ReplacePerks()
{
    self ClearPerks();

    self GivePerk("specialty_fastreload", 0) // Sleight of hand
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

    self.pers["gamemodeLoadout"]["loadoutKillstreak1"] = "specialty_scavenger_ks";
    self.pers["gamemodeLoadout"]["loadoutKillstreak2"] = "none";
    self.pers["gamemodeLoadout"]["loadoutKillstreak3"] = "none";

    if (!isDefined(self.pers["isBot"]) || !self.pers["isBot"])
	{
        self maps\mp\gametypes\_class::giveLoadout(self.team, "gamemode", false, true);
    }

	maps\mp\killstreaks\_killstreaks::clearKillstreaks();
}