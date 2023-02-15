#include maps\mp\gametypes\_hud_util;

Init()
{
    InitWelcomeMessage();
}

InitWelcomeMessage()
{
    level.welcome_message_icon = "rank_prestige10";

    PreCacheShader(level.welcome_message_icon);

    level thread OnPlayerConnected();
}

OnPlayerConnected()
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

		// Don't show first spawn text to bots
		if (isDefined(self.pers["isBot"]))
		{
			if (self.pers["isBot"])
			{
				continue; // skip
			}
		}

		if (!IsDefined(self.pers["saw_first_spawn_message"]) || !self.pers["saw_first_spawn_message"])
		{
			self.pers["saw_first_spawn_message"] = true;
			self ShowFirstSpawnMessage();
		}
	}
}

ShowFirstSpawnMessage()
{
    notifyData = spawnstruct();

    notifyData.iconName = level.welcome_message_icon;
    notifyData.titleText = "Welcome ^5" + self.name; // line 1
    notifyData.notifyText = "Enjoy your game on ^1 " + GetDvar("party_mapname"); // line 2
    notifyData.notifyText2 = "Join our Discord at ^5discord.gg/plutonium"; // line 3
    notifyData.glowColor = (0, 0, 0); // (0.3, 0.6, 0.3) is the default glow
    notifyData.sound = "mp_level_up";
    notifyData.duration = 7;
    notifyData.font = "DAStacks";
    notifyData.hideWhenInMenu = false;

    self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}