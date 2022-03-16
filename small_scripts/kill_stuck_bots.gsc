Init()
{
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
		self waittill("spawned_player");
		if (isDefined(self.pers["isBot"]))
		{
			if (self.pers["isBot"])
			{
				self thread KillStuckBots();
			}
		}
	}
}

KillStuckBots()
{
	self endon ("disconnect");
    level endon("game_ended");

	kills_before = self.pers["cur_kill_streak"];
	deaths_before = self.pers["deaths"];

	wait 30;

	kills_now = self.pers["cur_kill_streak"];
	deaths_now = self.pers["deaths"];

	if (kills_now == kills_before && deaths_before == deaths_now)
	{
		self Suicide();
	}
}

// Prints text in the bootstrapper
Debug(text)
{
    Print(text);
}