/*
======================================================================
|                         Game: Plutonium IW5 	                     |
|                   Description : Let players vote                   |
|              for a map and mode at the end of each game            |
|                            Author: Resxt                           |
======================================================================
|   https://github.com/Resxt/Plutonium-IW5-Scripts/tree/main/mapvote  |
======================================================================
*/

#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\_utility;

/* Entry point */

Init()
{
    if (GetDvarInt("mapvote_enable"))
    {
        replaceFunc(maps\mp\gametypes\_gamelogic::waittillFinalKillcamDone, ::OnKillcamEnd);

        InitMapvote();
    }
}



/* Init section */

InitMapvote()
{
    InitDvars();
    InitVariables();

    if (GetDvarInt("mapvote_debug"))
    {
        Print("[MAPVOTE] Debug mode is ON");
        wait 3;
        level thread StartVote();
        level thread ListenForEndVote();
    }
    else
    {
        // Starting the mapvote normally is handled by the replaceFunc in Init()
    }
}

InitDvars()
{
    SetDvarIfNotInitialized("mapvote_debug", false);

    SetDvarIfNotInitialized("mapvote_maps", "Seatown,mp_seatown:Dome,mp_dome:Arkaden,mp_plaza2:Bakaara,mp_mogadishu:Resistance,mp_paris:Downturn,mp_exchange:Bootleg,mp_bootleg:Carbon,mp_carbon:Hardhat,mp_hardhat:Lockdown,mp_alpha:Village,mp_village:Fallen,mp_lambeth:Outpost,mp_radar:Interchange,mp_interchange:Underground,mp_underground:Mission,mp_bravo:Piazza,mp_italy:Liberation,mp_park:Overwatch,mp_overwatch:Black Box,mp_morningwood:Sanctuary,mp_meteora:Foundation,mp_cement:Oasis,mp_qadeem:Terminal,mp_terminal_cls:Decommission,mp_shipbreaker:Off Shore,mp_roughneck:Gulch,mp_moab:Boardwalk,mp_boardwalk:Parish,mp_nola:Favela,mp_favela:Highrise,mp_highrise:Skidrow,mp_nightshift:Nuketown,mp_nuked:Rust,mp_rust");
    SetDvarIfNotInitialized("mapvote_modes", "Team Deathmatch,TDM_default:Domination,DOM_default");
    SetDvarIfNotInitialized("mapvote_additional_maps_dvars", "");
    SetDvarIfNotInitialized("mapvote_limits_maps", 0);
    SetDvarIfNotInitialized("mapvote_limits_modes", 0);
    SetDvarIfNotInitialized("mapvote_limits_max", 12);
    SetDvarIfNotInitialized("mapvote_sounds_menu_enabled", 1);
    SetDvarIfNotInitialized("mapvote_sounds_timer_enabled", 1);
    SetDvarIfNotInitialized("mapvote_colors_selected", "blue");
    SetDvarIfNotInitialized("mapvote_colors_unselected", "white");
    SetDvarIfNotInitialized("mapvote_colors_timer", "blue");
    SetDvarIfNotInitialized("mapvote_colors_timer_low", "red");
    SetDvarIfNotInitialized("mapvote_colors_help_text", "white");
    SetDvarIfNotInitialized("mapvote_colors_help_accent", "blue");
    SetDvarIfNotInitialized("mapvote_colors_help_accent_mode", "standard");
    SetDvarIfNotInitialized("mapvote_vote_time", 30);
    SetDvarIfNotInitialized("mapvote_blur_level", 2.5);
    SetDvarIfNotInitialized("mapvote_blur_fade_in_time", 2);
    SetDvarIfNotInitialized("mapvote_horizontal_spacing", 75);
    SetDvarIfNotInitialized("mapvote_display_wait_time", 1);
    SetDvarIfNotInitialized("mapvote_default_rotation_maps", "mp_dome:mp_nuked:mp_rust");
    SetDvarIfNotInitialized("mapvote_default_rotation_modes", "TDM_default");
    SetDvarIfNotInitialized("mapvote_default_rotation_min_players", 0);
    SetDvarIfNotInitialized("mapvote_default_rotation_max_players", 0);
}

InitVariables()
{
    mapsString = GetDvar("mapvote_maps");

    foreach (mapDvar in StrTok(GetDvar("mapvote_additional_maps_dvars"), ":"))
    {
        if (mapsString == " ")
        {
            mapsString = GetDvar(mapDvar);
        }
        else
        {
            mapsString = mapsString + ":" + GetDvar(mapDvar);
        }
    }

    mapsArray = StrTok(mapsString, ":");
    voteLimits = [];

    modesArray = StrTok(GetDvar("mapvote_modes"), ":");

    if (GetDvarInt("mapvote_limits_maps") == 0 && GetDvarInt("mapvote_limits_modes") == 0)
    {
        voteLimits = GetVoteLimits(mapsArray.size, modesArray.size);
    }
    else if (GetDvarInt("mapvote_limits_maps") > 0 && GetDvarInt("mapvote_limits_modes") == 0)
    {
        voteLimits = GetVoteLimits(GetDvarInt("mapvote_limits_maps"), modesArray.size);
    }
    else if (GetDvarInt("mapvote_limits_maps") == 0 && GetDvarInt("mapvote_limits_modes") > 0)
    {
        voteLimits = GetVoteLimits(mapsArray.size, GetDvarInt("mapvote_limits_modes"));
    }
    else
    {
        voteLimits = GetVoteLimits(GetDvarInt("mapvote_limits_maps"), GetDvarInt("mapvote_limits_modes"));
    }

    level.mapvote["limit"]["maps"] = voteLimits["maps"];
    level.mapvote["limit"]["modes"] = voteLimits["modes"];

    SetMapvoteData("map", mapsArray);
    SetMapvoteData("mode");

    level.mapvote["vote"]["maps"] = [];
    level.mapvote["vote"]["modes"] = [];
    level.mapvote["hud"]["maps"] = [];
    level.mapvote["hud"]["modes"] = [];
}



/* Player section */

/*
This is used instead of notifyonplayercommand("mapvote_up", "speed_throw") 
to fix an issue where players using toggle ads would have to press right click twice for it to register one right click.
With this instead it keeps scrolling every 0.25s until they right click again which is a better user experience
*/
ListenForRightClick()
{
    self endon("disconnect");

    while (true)
    {
        if (self AdsButtonPressed())
        {
            self notify("mapvote_up");
            wait 0.25;
        }

        wait 0.05;
    }
}

ListenForVoteInputs()
{
    self endon("disconnect");

    self thread ListenForRightClick();

    self notifyonplayercommand("mapvote_down", "+attack");
    self notifyonplayercommand("mapvote_select", "+gostand");
    self notifyonplayercommand("mapvote_unselect", "+usereload");
    self notifyonplayercommand("mapvote_unselect", "+activate");

    while(true)
    {
        input = self waittill_any_return("mapvote_down", "mapvote_up", "mapvote_select", "mapvote_unselect");

        section = self.mapvote["vote_section"];

        if (section == "end" && input != "mapvote_unselect")
        {
            continue; // stop/skip execution
        }
        else if (section == "mode" && level.mapvote["modes"]["by_index"].size <= 1 && input != "mapvote_unselect")
        {
            continue; // stop/skip execution
        }

        if (input == "mapvote_down")
        {
            if (self.mapvote[section]["hovered_index"] < (level.mapvote[section + "s"]["by_index"].size - 1))
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("mouse_click");
                }

                self UpdateSelection(section, (self.mapvote[section]["hovered_index"] + 1));
            }
        }
        else if (input == "mapvote_up")
        {
            if (self.mapvote[section]["hovered_index"] > 0)
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("mouse_click");
                }

                self UpdateSelection(section, (self.mapvote[section]["hovered_index"] - 1));
            }
        }
        else if (input == "mapvote_select")
        {
            if (GetDvarInt("mapvote_sounds_menu_enabled"))
            {
                self playlocalsound("mp_killconfirm_tags_pickup");
            }

            self ConfirmSelection(section);
        }
        else if (input == "mapvote_unselect")
        {
            if (section != "map")
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("mine_betty_click");
                }

                self CancelSelection(section);
            }
        }

        wait 0.05;
    }
}

OnPlayerDisconnect()
{
    self waittill("disconnect");

    if (self.mapvote["map"]["selected_index"] != -1)
    {
        level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]] = (level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]] - 1);
        level.mapvote["hud"]["maps"][self.mapvote["map"]["selected_index"]] SetValue(level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]]);
    }

    if (self.mapvote["mode"]["selected_index"] != -1)
    {
        level.mapvote["vote"]["modes"][self.mapvote["mode"]["selected_index"]] = (level.mapvote["vote"]["modes"][self.mapvote["mode"]["selected_index"]] - 1);
        level.mapvote["hud"]["modes"][self.mapvote["mode"]["selected_index"]] SetValue(level.mapvote["vote"]["modes"][self.mapvote["mode"]["selected_index"]]);
    }
}




/* Vote section */

CreateVoteMenu()
{
    spacing = 20;
    hudLastPosY = 0;
    sectionsSeparation = 0;
    modesCount = 0;

    if (level.mapvote["modes"]["by_index"].size > 1)
    {
        sectionsSeparation = 1;
        modesCount = level.mapvote["modes"]["by_index"].size;
    }

    hudLastPosY = 0 - ((((level.mapvote["maps"]["by_index"].size + modesCount + sectionsSeparation) * spacing) / 2) - (spacing / 2));

    for (mapIndex = 0; mapIndex < level.mapvote["maps"]["by_index"].size; mapIndex++)
    {
        mapVotesHud = CreateHudText(&"", "default", 1.5, "LEFT", "CENTER", GetDvarInt("mapvote_horizontal_spacing"), hudLastPosY, true, 0);
        mapVotesHud.color = GetGscColor(GetDvar("mapvote_colors_selected"));

        level.mapvote["hud"]["maps"][mapIndex] = mapVotesHud;

        foreach (player in GetHumanPlayers())
        {
            mapName = level.mapvote["maps"]["by_index"][mapIndex];

            player.mapvote["map"][mapIndex]["hud"] = player CreateHudText(mapName, "default", 1.5, "LEFT", "CENTER", 0 - (GetDvarInt("mapvote_horizontal_spacing")), hudLastPosY);

            if (mapIndex == 0)
            {
                player UpdateSelection("map", 0);
            }
            else
            {
                SetElementUnselected(player.mapvote["map"][mapIndex]["hud"]);
            }
        }

        hudLastPosY += spacing;
    }

    if (level.mapvote["modes"]["by_index"].size > 1)
    {
        hudLastPosY += spacing; // Space between maps and modes sections

        for (modeIndex = 0; modeIndex < level.mapvote["modes"]["by_index"].size; modeIndex++)
        {
            modeVotesHud = CreateHudText(&"", "default", 1.5, "LEFT", "CENTER", GetDvarInt("mapvote_horizontal_spacing"), hudLastPosY, true, 0);
            modeVotesHud.color = GetGscColor(GetDvar("mapvote_colors_selected"));

            level.mapvote["hud"]["modes"][modeIndex] = modeVotesHud;

            foreach (player in GetHumanPlayers())
            {
                player.mapvote["mode"][modeIndex]["hud"] = player CreateHudText(level.mapvote["modes"]["by_index"][modeIndex], "default", 1.5, "LEFT", "CENTER", 0 - (GetDvarInt("mapvote_horizontal_spacing")), hudLastPosY);

                SetElementUnselected(player.mapvote["mode"][modeIndex]["hud"]);
            }

            hudLastPosY += spacing;
        }
    }

    foreach(player in GetHumanPlayers())
    {
        player.mapvote["map"]["selected_index"] = -1;
        player.mapvote["mode"]["selected_index"] = -1;

        buttonsHelpMessage = "";

        if (GetDvar("mapvote_colors_help_accent_mode") == "standard")
        {
            buttonsHelpMessage = GetChatColor(GetDvar("mapvote_colors_help_text")) + "Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+attack}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go down - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+toggleads_throw}] OR [{+speed_throw}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go up - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+gostand}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to select - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+activate}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to undo";
        }
        else if(GetDvar("mapvote_colors_help_accent_mode") == "max")
        {
            buttonsHelpMessage = GetChatColor(GetDvar("mapvote_colors_help_text")) + "Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+attack}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "down " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+toggleads_throw}] OR [{+speed_throw}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "up " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+gostand}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "select " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+activate}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "undo";
        }

        player CreateHudText(buttonsHelpMessage, "default", 1.5, "CENTER", "CENTER", 0, 210); 
    }
}

CreateVoteTimer()
{
	soundFX = spawn("script_origin", (0,0,0));
	soundFX hide();
	
	timerhud = CreateTimer(GetDvarInt("mapvote_vote_time"), &"Vote ends in: ", "default", 1.5, "CENTER", "CENTER", 0, -210);		
    timerhud.color = GetGscColor(GetDvar("mapvote_colors_timer"));
	for (i = GetDvarInt("mapvote_vote_time"); i > 0; i--)
	{	
		if(i <= 5) 
		{
			timerhud.color = GetGscColor(GetDvar("mapvote_colors_timer_low"));

            if (GetDvarInt("mapvote_sounds_timer_enabled"))
            {
                soundFX playSound( "ui_mp_timer_countdown" );
            }
		}
		wait(1);
	}	
	level notify("mapvote_vote_end");
}

StartVote()
{
    level endon("end_game");

    for (i = 0; i < level.mapvote["maps"]["by_index"].size; i++)
    {
        level.mapvote["vote"]["maps"][i] = 0;
    }

    for (i = 0; i < level.mapvote["modes"]["by_index"].size; i++)
    {
        level.mapvote["vote"]["modes"][i] = 0;
    }

    level thread CreateVoteMenu();
    level thread CreateVoteTimer();

    foreach (player in GetHumanPlayers())
    {
        player SetBlurForPlayer(GetDvarInt("mapvote_blur_level"), GetDvarInt("mapvote_blur_fade_in_time"));

        player thread ListenForVoteInputs();
        player thread OnPlayerDisconnect();
    }
}

ListenForEndVote()
{
    level endon("end_game");
    level waittill("mapvote_vote_end");

    mostVotedMapIndex = 0;
    mostVotedMapVotes = 0;
    mostVotedModeIndex = 0;
    mostVotedModeVotes = 0;

    foreach (mapIndex in GetArrayKeys(level.mapvote["vote"]["maps"]))
    {
        if (level.mapvote["vote"]["maps"][mapIndex] > mostVotedMapVotes)
        {
            mostVotedMapIndex = mapIndex;
            mostVotedMapVotes = level.mapvote["vote"]["maps"][mapIndex];
        }
    }

    foreach (modeIndex in GetArrayKeys(level.mapvote["vote"]["modes"]))
    {
        if (level.mapvote["vote"]["modes"][modeIndex] > mostVotedModeVotes)
        {
            mostVotedModeIndex = modeIndex;
            mostVotedModeVotes = level.mapvote["vote"]["modes"][modeIndex];
        }
    }

    if (mostVotedMapVotes == 0)
    {
        mostVotedMapIndex = GetRandomElementInArray(GetArrayKeys(level.mapvote["vote"]["maps"]));

        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] No vote for map. Chosen random map index: " + mostVotedMapIndex);
        }
    }
    else
    {
        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] Most voted map has " + mostVotedMapVotes + " votes. Most voted map index: " + mostVotedMapIndex);
        }
    }

    if (mostVotedModeVotes == 0)
    {
        mostVotedModeIndex = GetRandomElementInArray(GetArrayKeys(level.mapvote["vote"]["modes"]));

        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] No vote for mode. Chosen random mode index: " + mostVotedModeIndex);
        }
    }
    else
    {
        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] Most voted mode has " + mostVotedModeVotes + " votes. Most voted mode index: " + mostVotedModeIndex);
        }
    }

    modeName = level.mapvote["modes"]["by_index"][mostVotedModeIndex];
    modeDsr = level.mapvote["modes"]["by_name"][level.mapvote["modes"]["by_index"][mostVotedModeIndex]];
    mapName = level.mapvote["maps"]["by_name"][level.mapvote["maps"]["by_index"][mostVotedMapIndex]];

    if (GetDvarInt("mapvote_debug"))
    {
        Print("[MAPVOTE] mapName: " + mapName);
        Print("[MAPVOTE] modeName: " + modeName);
        Print("[MAPVOTE] modeDsr: " + modeDsr);
        Print("[MAPVOTE] Rotating to " + mapName + " | " + modeName + " (" + modeDsr + ".dsr)");
    }

    cmdexec("load_dsr " + modeDsr);
	wait(0.05);
	cmdexec("map " + mapName);
}

SetMapvoteData(type, elements)
{
    limit = level.mapvote["limit"][type + "s"];

    availableElements = [];

    if (IsDefined(elements))
    {
        availableElements = elements;
    }
    else
    {
        availableElements = StrTok(GetDvar("mapvote_" + type + "s"), ":");
    }

    if (availableElements.size < limit)
    {
        limit = availableElements.size;
    }

    if (type == "map")
    {
        finalMapElements = [];

        foreach (mapElement in availableElements)
        {
            finalMapElement = StrTok(mapElement, ",");
            finalMapElements = AddElementToArray(finalMapElements, finalMapElement[0]);
            
            level.mapvote["maps"]["by_name"][finalMapElement[0]] = finalMapElement[1];
        }

        level.mapvote["maps"]["by_index"] = GetRandomUniqueElementsInArray(finalMapElements, limit);
    }
    else if (type == "mode")
    {
        finalElements = [];

        foreach (mode in GetRandomUniqueElementsInArray(availableElements, limit))
        {
            splittedMode = StrTok(mode, ",");
            finalElements = AddElementToArray(finalElements, splittedMode[0]);

            level.mapvote["modes"]["by_name"][splittedMode[0]] = splittedMode[1];
        }

        level.mapvote["modes"]["by_index"] = finalElements;
    }
}

/*
Gets the amount of maps and modes to display on screen
This is used to get default values if the limits dvars are not set
It will dynamically adjust the amount of maps and modes to show
*/
GetVoteLimits(mapsAmount, modesAmount)
{
    maxLimit = GetDvarInt("mapvote_limits_max");
    limits = [];

    if (!IsDefined(modesAmount))
    {
        if (mapsAmount <= maxLimit)
        {
            return mapsAmount;
        }
        else
        {
            return maxLimit;
        }
    }

    if ((mapsAmount + modesAmount) <= maxLimit)
    {
        limits["maps"] = mapsAmount;
        limits["modes"] = modesAmount;
    }
    else
    {
        if (mapsAmount >= (maxLimit / 2) && modesAmount >= (maxLimit))
        {
            limits["maps"] = (maxLimit / 2);
            limits["modes"] = (maxLimit / 2);
        }
        else
        {
            if (mapsAmount > (maxLimit / 2))
            {
                finalMapsAmount = 0;

                if (modesAmount <= 1)
                {
                    limits["maps"] = maxLimit;
                }
                else
                {
                    limits["maps"] = (maxLimit - modesAmount);
                }
                
                limits["modes"] = modesAmount;
            }
            else if (modesAmount > (maxLimit / 2))
            {
                limits["maps"] = mapsAmount;
                limits["modes"] = (maxLimit - mapsAmount);
            }
        }
    }
    
    return limits;
}

OnKillcamEnd()
{
    if (!IsDefined(level.finalkillcam_winner))
	{
	    if (isRoundBased() && !wasLastRound())
			return false;	

		wait GetDvarInt("mapvote_display_wait_time");
		DoRotation();

        return false;
    }
	
    level waittill("final_killcam_done");
	if (isRoundBased() && !wasLastRound())
		return true;

	wait GetDvarInt("mapvote_display_wait_time");
    DoRotation();

    return true;
}

ShouldRotateDefault()
{
    humanPlayersCount = GetHumanPlayers().size;

    if (GetDvarInt("mapvote_default_rotation_max_players") > 0 && humanPlayersCount >= GetDvarInt("mapvote_default_rotation_min_players") && humanPlayersCount <= GetDvarInt("mapvote_default_rotation_max_players"))
    {
        return true;
    }

    return false;
}

RotateDefault()
{
    cmdexec("load_dsr " + GetRandomElementInArray(StrTok(GetDvar("mapvote_default_rotation_modes"), ":")));
	wait(0.05);
	cmdexec("map " + GetRandomElementInArray(StrTok(GetDvar("mapvote_default_rotation_maps"), ":")));
}

DoRotation()
{
	if (ShouldRotateDefault())
	{
		RotateDefault();
	}
	else
	{
        StartVote();
        ListenForEndVote();
	}
}



/* HUD section */

UpdateSelection(type, index)
{
    if (type == "map" || type == "mode")
    {
        if (!IsDefined(self.mapvote[type]["hovered_index"]))
        {
            self.mapvote[type]["hovered_index"] = 0;
        }

        self.mapvote["vote_section"] = type;

        if (IsDefined(self.mapvote[type][self.mapvote[type]["hovered_index"]]))
        {
            SetElementUnselected(self.mapvote[type][self.mapvote[type]["hovered_index"]]["hud"]); // Unselect previous element
        }

        if (IsDefined(self.mapvote[type][index]))
        {
            SetElementSelected(self.mapvote[type][index]["hud"]); // Select new element
        }

        self.mapvote[type]["hovered_index"] = index; // Update the index
    }
    else if (type == "end")
    {
        self.mapvote["vote_section"] = "end";
    }
}

ConfirmSelection(type)
{
    self.mapvote[type]["selected_index"] = self.mapvote[type]["hovered_index"];
    level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]] = (level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]] + 1);
    level.mapvote["hud"][type + "s"][self.mapvote[type]["selected_index"]] SetValue(level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]]);

    if (type == "map")
    {
        modeIndex = 0;

        if (IsDefined(self.mapvote["mode"]["hovered_index"]))
        {
            modeIndex = self.mapvote["mode"]["hovered_index"];
        }

        self UpdateSelection("mode", modeIndex);
    }
    else if (type == "mode")
    {
        self UpdateSelection("end");
    }
}

CancelSelection(type)
{
    typeToCancel = "";

    if (type == "mode")
    {
        typeToCancel = "map";
    }
    else if (type == "end")
    {
        typeToCancel = "mode";
    }

    level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] = (level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] - 1);
    level.mapvote["hud"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] SetValue(level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]]);

    self.mapvote[typeToCancel]["selected_index"] = -1;

    if (type == "mode")
    {
        if (IsDefined(self.mapvote["mode"][self.mapvote["mode"]["hovered_index"]]))
        {
            SetElementUnselected(self.mapvote["mode"][self.mapvote["mode"]["hovered_index"]]["hud"]);
        }

        self.mapvote["vote_section"] = "map";
    }
    else if (type == "end")
    {
        self.mapvote["vote_section"] = "mode";
    }
}

SetElementSelected(element)
{
    element.color = GetGscColor(GetDvar("mapvote_colors_selected"));
}

SetElementUnselected(element)
{
    element.color = GetGscColor(GetDvar("mapvote_colors_unselected"));
}

CreateHudText(text, font, fontScale, relativeToX, relativeToY, relativeX, relativeY, isServer, value)
{
    hudText = "";

    if (IsDefined(isServer) && isServer)
    {
        hudText = CreateServerFontString( font, fontScale );
    }
    else
    {
        hudText = CreateFontString( font, fontScale );
    }

    if (IsDefined(value))
    {
        hudText.label = text;
        hudText SetValue(value);
    }
    else
    {
        hudText SetText(text);
    }

    hudText SetPoint(relativeToX, relativeToY, relativeX, relativeY);
    
    hudText.hideWhenInMenu = 1;
    hudText.glowAlpha = 0;

    return hudText;
}

CreateTimer(time, label, font, fontScale, relativeToX, relativeToY, relativeX, relativeY)
{
	timer = createServerTimer(font, fontScale);	
	timer setpoint(relativeToX, relativeToY, relativeX, relativeY);
	timer.label = label; 
    timer.hideWhenInMenu = 1;
    timer.glowAlpha = 0;
	timer setTimer(time);
	
	return timer;
}



/* Utils section */

SetDvarIfNotInitialized(dvar, value)
{
	if (!IsInitialized(dvar))
    {
        SetDvar(dvar, value);
    }
}

IsInitialized(dvar)
{
	result = GetDvar(dvar);
	return result != "";
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}

GetHumanPlayers()
{
    humanPlayers = [];

    foreach (player in level.players)
    {
        if (!player IsBot())
        {
            humanPlayers = AddElementToArray(humanPlayers, player);
        }
    }

    return humanPlayers;
}

GetRandomElementInArray(array)
{
    return array[GetArrayKeys(array)[randomint(array.size)]];
}

GetRandomUniqueElementsInArray(array, limit)
{
    finalElements = [];

    for (i = 0; i < limit; i++)
    {
        findElement = true;

        while (findElement)
        {
            randomElement = GetRandomElementInArray(array);

            if (!ArrayContainsValue(finalElements, randomElement))
            {
                finalElements = AddElementToArray(finalElements, randomElement);

                findElement = false;
            }
        }
    }

    return finalElements;
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

AddElementToArray(array, element)
{
    array[array.size] = element;
    return array;
}

GetGscColor(colorName)
{
    switch (colorName)
	{
        case "red":
        return (1, 0, 0.059);

        case "green":
        return (0.549, 0.882, 0.043);

        case "yellow":
        return (1, 0.725, 0);

        case "blue":
        return (0, 0.553, 0.973);

        case "cyan":
        return (0, 0.847, 0.922);

        case "purple":
        return (0.427, 0.263, 0.651);

        case "white":
        return (1, 1, 1);

        case "grey":
        case "gray":
        return (0.137, 0.137, 0.137);

        case "black":
        return (0, 0, 0);
	}
}

GetChatColor(colorName)
{
    switch(colorName)
    {
        case "red":
        return "^1";

        case "green":
        return "^2";

        case "yellow":
        return "^3";

        case "blue":
        return "^4";

        case "cyan":
        return "^5";

        case "purple":
        return "^6";

        case "white":
        return "^7";

        case "grey":
        case "gray":
        return "^0";

        case "black":
        return "^0";
    }
}