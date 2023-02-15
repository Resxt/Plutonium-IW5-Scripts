#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_class;
//#include maps\mp\bots\_bot_utility; // Uncomment if using Bot Warfare
#include maps\mp\_utility;

Init()
{
    InitKamikazeMode();
}

InitKamikazeMode()
{
    SetGameLimits(75, 15);

    replacefunc(maps\mp\_utility::allowClassChoice, ::ReplaceAllowClassChoice);
    replacefunc(maps\mp\_utility::allowTeamChoice, ::ReplaceAllowTeamChoice);

    level.kamikaze_attack_detonate_interval_time = 0.75; // The time between two attacks when holding the attack button

    level.kamikaze_player_default_radius = 350;
    level.kamikaze_player_default_max_damage = 2000;
    level.kamikaze_player_default_min_damage = 1000;

    level.kamikaze_player_detonate_reduce_time = 0.375;
    level.kamikaze_player_increase_radius = 12.5;

    level.kamikaze_bonus_increase_radius_kills = 5;
    level.kamikaze_bonus_decrease_detonate_interval_kills = 15;

    SetDvar("player_sustainAmmo", 1);
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

OnPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);

        player.pers["kamikaze_radius"] = level.kamikaze_player_default_radius;
        player.pers["kamikaze_max_damage"] = level.kamikaze_player_default_max_damage;
        player.pers["kamikaze_min_damage"] = level.kamikaze_player_default_min_damage;
        player.pers["kamikaze_detonate_interval_time"] = 3;
        player.pers["kamikaze_radius_increase_kills"] = level.kamikaze_bonus_increase_radius_kills;
        player.pers["kamikaze_detonate_decrease_kills"] = level.kamikaze_bonus_decrease_detonate_interval_kills;

        player.last_registered_kills = 0;

        player thread OnPlayerSpawned();
        player thread OnPlayerKill();

        if (!player IsBot())
        {
            player DisplayPlayerRadius();
            player DisplayPlayerDetonationInterval();
        }
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("changed_kit");

        self.pers["detonate_allowed"] = true;

        self ClearPlayerClass();
        self ReplaceWeapons();
        self GiveKamikazePerks();

        self thread OnPlayerDetonate();
        self thread OnDetonateAllowed();
        self thread OnDetonateDisallowed();
    }
}

OnPlayerDetonate()
{
    self endon("disconnect");
    self endon("death");

    for(;;)
    {
        self waittill( "detonate" );

        if (self.pers["detonate_allowed"])
        {
            self DetonatePlayer();
            
            self notify("detonate_disallowed");
        }
    }
}

OnDetonateAllowed()
{
    self endon("disconnect");
    self endon("death");

    for(;;)
    {
        self waittill( "detonate_allowed" );

        self.pers["detonate_allowed"] = true;
        self playlocalsound("ammo_crate_use");
    }
}

OnDetonateDisallowed()
{
    self endon("disconnect");
    self endon("death");

    for(;;)
    {
        self waittill( "detonate_disallowed" );

        self.pers["detonate_allowed"] = false;

        wait self.pers["kamikaze_detonate_interval_time"];

        self notify("detonate_allowed");
    }
}

OnPlayerKill()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill( "killed_enemy" );

        if (self.kills >= self.pers["kamikaze_radius_increase_kills"] && self.last_registered_kills < self.pers["kamikaze_radius_increase_kills"])
        {
            self playlocalsound("copycat_steal_class");

            self.pers["kamikaze_radius_increase_kills"] = self.pers["kamikaze_radius_increase_kills"] + level.kamikaze_bonus_increase_radius_kills;
            self.pers["kamikaze_radius"] = self.pers["kamikaze_radius"] + level.kamikaze_player_increase_radius;
            
            self.player_radius_text setValue(self.pers["kamikaze_radius"]);
        }

        if (self.kills >= self.pers["kamikaze_detonate_decrease_kills"] && self.last_registered_kills < self.pers["kamikaze_detonate_decrease_kills"])
        {
            self playlocalsound("copycat_steal_class");

            self.pers["kamikaze_detonate_decrease_kills"] = self.pers["kamikaze_detonate_decrease_kills"] + level.kamikaze_bonus_decrease_detonate_interval_kills;
            self.pers["kamikaze_detonate_interval_time"] = self.pers["kamikaze_detonate_interval_time"] - level.kamikaze_player_detonate_reduce_time;

            self.player_detonation_interval_text setValue(self.pers["kamikaze_detonate_interval_time"]);
        }

        self.last_registered_kills = self.kills;
    }
}

DetonatePlayer()
{
    self playsound("detpack_explo_default");
    playfx(level.c4death, self.origin);
    self radiusdamage( self.origin, self.pers["kamikaze_radius"], self.pers["kamikaze_max_damage"], self.pers["kamikaze_min_damage"], self );
}

ReplaceWeapons()
{
    self TakeAllWeapons();

    newWeapon = "c4death_mp";

    self GiveWeapon(newWeapon);
    self SwitchToWeapon(newWeapon);
    self SetSpawnWeapon(newWeapon);
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

GiveKamikazePerks()
{
    self GivePerk("specialty_longersprint", false); // Extreme conditioning
    self GivePerk(GetProPerkName("specialty_longersprint"), false); // Extreme conditioning PRO

    self GivePerk(GetProPerkName("specialty_bulletaccuracy"), false); // Steady aim PRO
    self GivePerk(GetProPerkName("specialty_quieter"), false); // Dead silence PRO
}

DisplayPlayerRadius()
{
    self endon ("disconnect");
    level endon("game_ended");

	self.player_radius_text = createFontString( "Objective", 0.65 );
	self.player_radius_text setPoint( "CENTER", "TOP", 0, 18.75 );
    self.player_radius_text.label = &"^5Your explosions radius: ";
	self.player_radius_text.hideWhenInMenu = false;
    self.player_radius_text.foreground = false;

    if (!self IsBot())
    {
        self.player_radius_text setValue(self.pers["kamikaze_radius"]);
    }
}

DisplayPlayerDetonationInterval()
{
    self endon ("disconnect");
    level endon("game_ended");

	self.player_detonation_interval_text = createFontString( "Objective", 0.65 );
	self.player_detonation_interval_text setPoint( "CENTER", "TOP", 0, 7.5 );
    self.player_detonation_interval_text.label = &"^5Your detonations interval: ";
	self.player_detonation_interval_text.hideWhenInMenu = false;
    self.player_detonation_interval_text.foreground = false;

    if (!self IsBot())
    {
        self.player_detonation_interval_text setValue(self.pers["kamikaze_detonate_interval_time"]);
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

ReplaceAllowClassChoice()
{
	return false;	
}

ReplaceAllowTeamChoice()
{   
    return false;
}

GetProPerkName(perkName)
{
    return tablelookup( "mp/perktable.csv", 1, perkName, 8 );
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}