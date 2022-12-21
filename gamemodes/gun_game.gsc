/*
======================================================================
|                         Game: Plutonium IW5 	                     |
|                   Description : Gun game recreation                |
|                            Author: Resxt                           |
======================================================================
| https://github.com/Resxt/Plutonium-IW5-Scripts/tree/main/gamemodes |
======================================================================
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_class;
#include maps\mp\gametypes\_hud_util;
//#include maps\mp\bots\_bot_utility; // Uncomment if using Bot Warfare

/* Entry point */

Init()
{
    InitGunGame();
}



/* Init section */ 

InitGunGame()
{
    replacefunc(maps\mp\_utility::allowTeamChoice, ::ReplaceAllowTeamChoice);
	replacefunc(maps\mp\_utility::allowClassChoice, ::ReplaceAllowClassChoice);

    InitConfigVariables();
    InitWeaponVariables();

    InitCurrentGameWeapons();
    SetGameLimits(0, (level.gun_game_weapons_amount / 5)); // Leave the kills limit at zero. The score will set itself in OnPlayerKill() whenever a player is at the last weapon. This is to prevent multi kills from counting as multi kills
    
    level thread OnPlayerConnect();
    
    if (level.gun_game_debug)
    {
        level thread DebugOnPlayerSay();

        DebugArray("level.gun_game_current_game_weapons", level.gun_game_current_game_weapons);
    }
}

InitConfigVariables()
{
    level.gun_game_debug = false;
    level.gun_game_weapons_amount = 50; // If level.gun_game_weapons_unique_check is set to weapon then this cannot be higher than 51 (the amount of usable weapons)
    level.gun_game_weapons_attachment_scope_percent = 75; // The percent of chance a weapon will have a scope (max 100)
    level.gun_game_weapons_attachment_other_percent = 75; // The percent of chance a weapon will have an attachment other than a scope (max 100)
    level.gun_game_snipers_shotguns_normal_scope_percent = 90; // The percent of chance a sniper will have the default scope (max 100)
    level.gun_game_weapons_primary_weapons_percent = 90; // The percent of chance a random weapon will be a primary weapon. This is used when both level.gun_game_available_weapons_config arrays values aren't "none" (max 100)
    level.gun_game_available_weapons_config["primary_weapons"] = ["assault_rifles", "sub_machine_guns", "light_machine_guns", "sniper_rifles", "shotguns"]; // ["none"] OR array of level.gun_game_available_weapons["primary_weapons"] keys
    level.gun_game_available_weapons_config["secondary_weapons"] = ["machine_pistols", "handguns", "launchers"]; // ["none"] OR array of level.gun_game_available_weapons["secondary_weapons"] keys
    level.gun_game_weapons_unique_check = "weapon"; // weapon OR weapon_attachments OR none
}

InitWeaponVariables()
{
    level.gun_game_available_weapons["primary_weapons"]["assault_rifles"] = ["iw5_m4_mp", "iw5_m16_mp", "iw5_scar_mp", "iw5_cm901_mp", "iw5_type95_mp", "iw5_g36c_mp", "iw5_acr_mp", "iw5_mk14_mp", "iw5_ak47_mp", "iw5_fad_mp"];
    level.gun_game_available_weapons["primary_weapons"]["sub_machine_guns"] = ["iw5_mp5_mp", "iw5_ump45_mp", "iw5_pp90m1_mp", "iw5_p90_mp", "iw5_m9_mp", "iw5_mp7_mp", "iw5_ak74u_mp"];
    level.gun_game_available_weapons["primary_weapons"]["light_machine_guns"] = ["iw5_sa80_mp", "iw5_mg36_mp", "iw5_pecheneg_mp", "iw5_mk46_mp", "iw5_m60_mp"];
    level.gun_game_available_weapons["primary_weapons"]["sniper_rifles"] = ["iw5_barrett_mp", "iw5_l96a1_mp", "iw5_dragunov_mp", "iw5_as50_mp", "iw5_rsass_mp", "iw5_msr_mp", "iw5_cheytac_mp"];
    level.gun_game_available_weapons["primary_weapons"]["shotguns"] = ["iw5_usas12_mp", "iw5_ksg_mp", "iw5_spas12_mp", "iw5_aa12_mp", "iw5_striker_mp", "iw5_1887_mp"];
    level.gun_game_available_weapons["primary_weapons"]["riot_shield"] = ["riotshield_mp"];

    level.gun_game_available_weapons["secondary_weapons"]["machine_pistols"] = ["iw5_g18_mp", "iw5_fmg9_mp", "iw5_mp9_mp", "iw5_skorpion_mp"];
    level.gun_game_available_weapons["secondary_weapons"]["handguns"] = ["iw5_44magnum_mp", "iw5_usp45_mp", "iw5_deserteagle_mp", "iw5_mp412_mp", "iw5_p99_mp", "iw5_fnfiveseven_mp"];
    level.gun_game_available_weapons["secondary_weapons"]["launchers"] = ["iw5_smaw_mp", "javelin_mp", "xm25_mp", "m320_mp", "rpg_mp"]; // stinger is removed. Cannot shoot at enemies (at least without a GSC script that I don't have)

    level.gun_game_available_attachments["weapon_assault"][0] = ["reflex", "acog", "eotech", "hybrid", "thermal"];
    level.gun_game_available_attachments["weapon_assault"][1] = ["silencer", "heartbeat", "xmags"]; // gl and shotgun are removed and untested. I believe an attachment that changes the weapon's attack/fire to a generic one doesn't belong in gun game
    level.gun_game_available_attachments["weapon_smg"][0] = ["reflexsmg", "acogsmg", "eotechsmg", "hamrhybrid", "thermalsmg"];
    level.gun_game_available_attachments["weapon_smg"][1] = ["silencer", "rof", "xmags"];
    level.gun_game_available_attachments["weapon_lmg"][0] = ["reflexlmg", "acog", "eotechlmg", "thermal"];
    level.gun_game_available_attachments["weapon_lmg"][1] = ["silencer", "grip", "rof", "heartbeat", "xmags"];
    level.gun_game_available_attachments["weapon_sniper"][0] = ["acog", "thermal"]; // variable scope is removed and untested. Doesn't really add anything useful and would mess the percent of chance a sniper has a different scope
    level.gun_game_available_attachments["weapon_sniper"][1] = ["silencer03", "heartbeat", "xmags"];
    level.gun_game_available_attachments["weapon_shotgun"][0] = ["reflex", "eotech"];
    level.gun_game_available_attachments["weapon_shotgun"][1] = ["grip", "silencer03", "xmags"];

    level.gun_game_available_attachments["weapon_machine_pistol"][0] = ["reflexsmg", "eotechsmg"]; // thanks to this you can have a scope with a silencer/akimbo/xmags attachment
    level.gun_game_available_attachments["weapon_machine_pistol"][1] = ["silencer02", "akimbo", "xmags"];
    level.gun_game_available_attachments["weapon_pistol"][0] = ["akimbo", "tactical"]; // thanks to this you can have akimbo silencers/xmags and tactical silencers/xmags pistols
    level.gun_game_available_attachments["weapon_pistol"][1] = ["silencer02", "xmags"];

    level.gun_game_available_camos = ["camo01", "camo02", "camo03", "camo04", "camo05", "camo06", "camo07", "camo08", "camo09", "camo10", "camo11", "camo12", "camo13"]; // camos are ordered the same way that they are in-game. camo11 is gold
}

InitCurrentGameWeapons()
{
    level.gun_game_current_game_weapons = [];
    gunGameCurrentGameAcceptedWeapons = [];
    gunGameCurrentGameBaseWeapons = [];
    gunGameCurrentGameWeapons = [];

    for (i = 0; i < level.gun_game_weapons_amount; i++)
    {
        findWeapon = true;

        while (findWeapon)
        {
            newWeapon = GetRandomWeapon();

            if (level.gun_game_weapons_unique_check == "weapon" && !ArrayContainsValue(gunGameCurrentGameBaseWeapons, GetBaseWeaponName(newWeapon)))
            {
                findWeapon = false;
                gunGameCurrentGameAcceptedWeapons = AddElementToArray(gunGameCurrentGameAcceptedWeapons, newWeapon);
                gunGameCurrentGameBaseWeapons = AddElementToArray(gunGameCurrentGameBaseWeapons, GetBaseWeaponName(newWeapon));
            }
            else if (level.gun_game_weapons_unique_check == "weapon_attachments" && !ArrayContainsValue(gunGameCurrentGameWeapons, GetWeaponNameWithoutCamo(newWeapon)))
            {
                findWeapon = false;
                gunGameCurrentGameAcceptedWeapons = AddElementToArray(gunGameCurrentGameAcceptedWeapons, newWeapon);
                gunGameCurrentGameWeapons = AddElementToArray(gunGameCurrentGameWeapons, GetWeaponNameWithoutCamo(newWeapon));
            }
            else if (level.gun_game_weapons_unique_check == "none")
            {
                findWeapon = false;
                gunGameCurrentGameAcceptedWeapons = AddElementToArray(gunGameCurrentGameAcceptedWeapons, newWeapon);
            }
        }
    }

    level.gun_game_current_game_weapons = gunGameCurrentGameAcceptedWeapons;
}



/* Logic section */

GetRandomWeapon()
{
    randomWeapon = GetRandomBaseWeapon();

    if (GetWeaponClass(randomWeapon) != "weapon_projectile" && randomWeapon != "riotshield_mp")
    {
        randomWeapon = randomWeapon + GetRandomAttachments(randomWeapon);
    }

    if (IsPrimaryWeapon(randomWeapon) && randomWeapon != "riotshield_mp")
    {
        randomWeapon = randomWeapon + GetRandomCamo();
    }

    return randomWeapon;
}

GetRandomBaseWeapon()
{
    weaponsFilteredByType = []; // Example: primary_weapons
    weaponsFilteredByCategory = []; // Example: assault_rifles
    randomWeapon = "";

    // Array of primaries and array of secondaries
    if (level.gun_game_available_weapons_config["primary_weapons"][0] != "none" && level.gun_game_available_weapons_config["secondary_weapons"][0] != "none" )
    {
        typeKey = "";

        if (BooleanFromPercentage(level.gun_game_weapons_primary_weapons_percent))
        {
            typeKey = "primary_weapons";
        }
        else
        {
            typeKey = "secondary_weapons";
        }

        categoryKey = GetRandomElementInArray(level.gun_game_available_weapons_config[typeKey]);

        weaponsFilteredByCategory = level.gun_game_available_weapons[typeKey][categoryKey];
    }
    // Array of primaries and no secondaries
    else if (level.gun_game_available_weapons_config["primary_weapons"][0] != "none" && level.gun_game_available_weapons_config["secondary_weapons"][0] == "none")
    {
        typeKey = "primary_weapons";
        categoryKey = GetRandomElementInArray(level.gun_game_available_weapons_config[typeKey]);

        weaponsFilteredByCategory = level.gun_game_available_weapons[typeKey][categoryKey];
    }
    // No primaries and array of secondaries
    else if (level.gun_game_available_weapons_config["primary_weapons"][0] == "none" && level.gun_game_available_weapons_config["secondary_weapons"][0] != "none")
    {
        typeKey = "secondary_weapons";
        categoryKey = GetRandomElementInArray(level.gun_game_available_weapons_config[typeKey]);

        weaponsFilteredByCategory = level.gun_game_available_weapons[typeKey][categoryKey];
    }

    randomWeapon = GetRandomElementInArray(weaponsFilteredByCategory); // Example: iw5_acr_mp

    return randomWeapon;
}

GetRandomAttachments(weaponName)
{
    weaponClass = GetWeaponClass(weaponName);
    scopeChancePercent = level.gun_game_weapons_attachment_scope_percent;
    attachments = "";

    if (weaponClass == "weapon_sniper" || weaponClass == "weapon_shotgun")
    {
        scopeChancePercent = (100 - level.gun_game_snipers_shotguns_normal_scope_percent);
    }
    else if (!IsPrimaryWeapon(weaponName))
    {
        scopeChancePercent = (scopeChancePercent / 2.5);
    }

    if (BooleanFromPercentage(scopeChancePercent))
    {
        attachment = GetRandomElementInArray(level.gun_game_available_attachments[weaponClass][0]);

        if (!AttachmentIsBanned(weaponName, attachment))
        {
            attachments = "_" + attachment;
        }
    }
    else
    {
        defaultScope = GetDefaultWeaponScope(weaponName);

        if (defaultScope != "")
        {
            attachments = "_" + defaultScope;
        }
    }

    if (BooleanFromPercentage(level.gun_game_weapons_attachment_other_percent))
    {
        attachment = GetRandomElementInArray(level.gun_game_available_attachments[weaponClass][1]);

        if (!AttachmentIsBanned(weaponName, attachment))
        {
            attachments = attachments + "_" + attachment;
        }
    }

    attachments = FixReversedAttachments(weaponName, attachments);
    
    return attachments;
}

GetRandomCamo()
{
    return "_" + GetRandomElementInArray(level.gun_game_available_camos);
}

GiveGunGameWeapon(spawn)
{
    self TakeAllWeapons();

    newWeapon = level.gun_game_current_game_weapons[self.pers["gun_game_current_index"]];

    self GiveWeapon(newWeapon);
    self SwitchToWeapon(newWeapon);
    self GiveMaxAmmo(newWeapon);

    if (spawn)
    {
        self SetSpawnWeapon(newWeapon);
    }
}

GiveGunGamePerks()
{
    self GivePerk("specialty_fastreload", false); // Sleight of hand
    self GivePerk("specialty_longersprint", false); // Extreme conditioning
    self GivePerk(GetProPerkName("specialty_longersprint"), false); // Extreme conditioning PRO
    self GivePerk("specialty_quickdraw", false); // Quickdraw
    self GivePerk("specialty_bulletaccuracy", false); // Steady aim
    self GivePerk(GetProPerkName("specialty_bulletaccuracy"), false); // Steady aim PRO
    self GivePerk(GetProPerkName("specialty_quieter"), false); // Dead silence PRO
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

AttachmentIsBanned(weaponName, attachmentName)
{
    if (GetBaseWeaponName(weaponName) == "iw5_ak74u_mp")
    {
        if (attachmentName == "hamrhybrid") // doesn't exist
        {
            return true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_shotgun")
    {
        if (GetBaseWeaponName(weaponName) == "iw5_1887_mp") // doesn't exist
        {
            return true;
        }
        else if (attachmentName == "silencer03") // bad/unfun
        {
            return true;
        }
    }
    else if (GetBaseWeaponName(weaponName) == "iw5_mp412_mp" || GetBaseWeaponName(weaponName) == "iw5_44magnum_mp" || GetBaseWeaponName(weaponName) == "iw5_deserteagle_mp")
    {
        if (attachmentName == "silencer02") // works but makes a silencer float on top of the player's on his screen
        {
            return true;
        }
    }

    return false;
}

/*
In some cases certain attachments considered as primary attachments (for example scopes) should come after the other attachment, here we fix this
*/
FixReversedAttachments(weaponName, attachments)
{
    reverse = false;
    attachmentsArray = StrTok(attachments, "_");

    if (attachmentsArray.size < 2)
    {
        return attachments;
    }

    if (GetWeaponClass(weaponName) == "weapon_assault")
    {
        if (attachmentsArray[1] == "heartbeat" && attachmentsArray[0] != "eotech" && attachmentsArray[0] != "acog" && attachmentsArray[0] != "thermal")
        {
            reverse = true;
        }
        else if (attachmentsArray[0] == "thermal" && attachmentsArray[1] != "xmags")
        {
            reverse = true;
        }
        else if (attachmentsArray[0] == "hybrid" && attachmentsArray[1] != "xmags" && attachmentsArray[1] != "silencer")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_smg")
    {
        if (attachmentsArray[0] == "thermalsmg" && attachmentsArray[1] != "xmags")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_lmg")
    {
        if (attachmentsArray[1] == "grip" && attachmentsArray[0] != "acog" && attachmentsArray[0] != "eotechlmg")
        {
            reverse = true;
        }
        else if (attachmentsArray[1] == "heartbeat" && attachmentsArray[0] != "eotechlmg" && attachmentsArray[0] != "acog")
        {
            reverse = true;
        }
        else if (attachmentsArray[0] == "thermal" && attachmentsArray[1] != "xmags")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_sniper")
    {
        if (attachmentsArray[1] == "heartbeat" && (attachmentsArray[0] == "rsassscope" || attachmentsArray[0] == "l96a1scope" || attachmentsArray[0] == "msrscope"))
        {
            reverse = true;
        }
        else if (attachmentsArray[0] == "thermal" && (attachmentsArray[1] != "xmags" || attachmentsArray[1] == "silencer03"))
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_shotgun")
    {
        if (attachmentsArray[1] == "grip" && attachmentsArray[0] != "eotech")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_machine_pistol")
    {
        if (attachmentsArray[1] == "akimbo")
        {
            reverse = true;
        }
    }
    else if (GetWeaponClass(weaponName) == "weapon_pistol")
    {
        if (attachmentsArray[0] == "tactical" && attachmentsArray[1] == "silencer02")
        {
            reverse = true;
        }
    }

    if (reverse)
    {
        return "_" + attachmentsArray[1] + "_" + attachmentsArray[0];
    }
    else
    {
        return attachments;
    }
}

GetDefaultWeaponScope(weaponName)
{
    switch(GetBaseWeaponName(weaponName))
    {
        case "iw5_barrett_mp":
            return "barrettscope";
        case "iw5_l96a1_mp":
            return "l96a1scope";
        case "iw5_dragunov_mp":
            return "dragunovscope";
        case "iw5_as50_mp":
            return "as50scope";
        case "iw5_rsass_mp":
            return "rsassscope";
        case "iw5_msr_mp":
            return "msrscope";
        case "iw5_cheytac_mp":
            return "cheytacscope";
    }

    return "";
}



/* Player section */

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);

        player.pers["gun_game_current_index"] = 0;
        player.pers["gun_game_current_weapon"] = level.gun_game_current_game_weapons[0];
        player.pers["previous_score"] = 0;

        player thread OnPlayerSpawned();
        player thread OnPlayerKill();
        player thread OnPlayerReload();

        if (!player IsBot())
        {
            player thread DisplayWeaponProgression();
        }
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("spawned_player");

        self ClearPlayerClass();
        self DisableWeaponPickup();
        
        GiveGunGameWeapon(true);
        GiveGunGamePerks();
    }
}

OnPlayerKill()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill( "killed_enemy" );

        self.pers["previous_score"] = (self.pers["previous_score"] + 50); // Prevent multi kills from giving score multiple times. This way our score is always equal to our current weapon index
        self.score = self.pers["previous_score"];
        self.pers["score"] = self.pers["previous_score"];

        if (self.score == (50 * level.gun_game_weapons_amount) - 50) // If we are at the last weapon
        {
            SetGameLimits(level.gun_game_weapons_amount); // Change the score limit (originally at 0 to prevent a multi kill bug) to one kill from now
        }

        self.pers["gun_game_current_index"]++;
        self.pers["gun_game_current_weapon"] = level.gun_game_current_game_weapons[self.pers["gun_game_current_index"]];

        if (self.pers["gun_game_current_index"] < level.gun_game_weapons_amount)
        {
            GiveGunGameWeapon(false);
            
            if (self.pers["gun_game_current_index"] == (level.gun_game_weapons_amount - 1   )) // last weapon obtained
            {
                maps\mp\_utility::playsoundonplayers( "mp_enemy_obj_captured" ); 
            }
            else
            {
                self playlocalsound( "mp_war_objective_taken" );
            }
        }
        else
        {
            self.pers["gun_game_current_index"] = (level.gun_game_weapons_amount - 1); // Reset the index to max weapon index. This is so that we don't display Weapon: 19/18 for example
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

        self GiveMaxAmmo( self.pers["gun_game_current_weapon"] );
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



/* HUD section */

DisplayWeaponProgression()
{
    self endon( "disconnect" );

	info_text = createFontString( "Objective", 0.65 );
	info_text setPoint( "CENTER", "TOP", 0, 7.5 );
	info_text.hideWhenInMenu = false;

    while(true)
    {
        if (!IsDefined(self.pers["gun_game_current_index_display"]) || self.pers["gun_game_current_index_display"] != (self.pers["gun_game_current_index"] + 1))
        {
            self.pers["gun_game_current_index_display"] = self.pers["gun_game_current_index"] + 1; // since the index starts at 0 we add 1 to display an index that makes sense for players
            info_text setText("^7WEAPON: " + self.pers["gun_game_current_index_display"] + "/" + level.gun_game_weapons_amount);
        }

        wait 0.01;
    }
}



/* Utils section */

GetProPerkName(perkName)
{
    return tablelookup( "mp/perktable.csv", 1, perkName, 8 );
}

GetRandomElementInArray(array)
{
    return array[GetArrayKeys(array)[randomint(array.size)]];
}

GetRandomArrayKey(array)
{
    return GetArrayKeys(array)[randomint(array.size)];
}

GetBaseWeaponName(weaponName)
{
    weaponCode = StrTok(weaponName, "_");

    if (weaponCode.size < 3)
    {
        return weaponName;
    }
	
	return weaponCode[0] + "_" + weaponCode[1] + "_" + weaponCode[2]; // Example: iw5_msr_mp
}

GetWeaponNameWithoutCamo(weaponName)
{
    return GetSubStr(weaponName, 0, weaponName.size - 7); // Example: iw5_acr_mp_camo01 = iw5_acr_mp
}

AddElementToArray(array, element)
{
    array[array.size] = element;
    return array;
}

ArrayContainsValue(array, valueToFind)
{
    if (array.size == 0)
    { 
        return false;
    }

    foreach (value in array)
    {
        if (value == valueToFind)
        {
            return true;
        }
    }

    return false;
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}

IsPrimaryWeapon(weaponName)
{
    if (GetWeaponClass(weaponName) == "weapon_machine_pistol" || GetWeaponClass(weaponName) == "weapon_pistol" || GetWeaponClass(weaponName) == "weapon_projectile")
    {
        return false;
    }

    return true;
}

/*
<percent> The percent of chance that it will return true
*/
BooleanFromPercentage(percent)
{
    return randomint(100) <= percent;
}



/* Replaced functions section */

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

ReplaceAllowClassChoice()
{
	return false;	
}



/* Debug section */

Debug(key, value)
{
    Print("[DEBUG] " + key + ": " + value);
}

DebugArray(key, array)
{
    Print("[DEBUG] " + key);
    
    foreach (value in array)
    {
        Print(value);
    }
}

/*
Go to the next weapon whenever you type something in the chat
To quickly cycle through weapons it is recommend to use the bootstrapper and type `say text`
Then use up arrow to quickly get the command again and press enter to run it
Allows you to quickly go to the next weapon, useful to find broken weapon combinations and update FixReversedAttachments()
*/
DebugOnPlayerSay()
{
    level endon( "game_ended" );

    for(;;)
    {
        level waittill( "say", message, player );

        if (player.pers["gun_game_current_index"] < (level.gun_game_weapons_amount - 1))
        {
            player notify("killed_enemy");
        }
        else
        {
            player IPrintLnBold("CANNOT GIVE WEAPON, YOU ARE AT THE MAX INDEX");
        }
    }
}