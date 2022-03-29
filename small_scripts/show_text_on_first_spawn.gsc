#include maps\mp\gametypes\_hud_util;

Init()
{
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
    first_spawn_message = "^1Read the rules by typing !rules in the chat";
	
	self IPrintLnBold(first_spawn_message);
    wait 3;
    self IPrintLnBold(first_spawn_message);
}