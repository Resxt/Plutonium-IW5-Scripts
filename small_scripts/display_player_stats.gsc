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

        // Don't thread DisplayPlayerKillstreak() on bots
        if (isDefined(player.pers["isBot"]))
		{
			if (player.pers["isBot"])
			{
				return;
			}
		}

        player thread DisplayPlayerKillstreak();
    }
}


DisplayPlayerKillstreak()
{
    self endon ("disconnect");
    level endon("game_ended");

    self.stats_text = createFontString( "Objective", 0.65 );
    self.stats_text setPoint( "CENTER", "TOP", "CENTER", 7.5 );

    while(true)
    {
        self.playerstreak = self.pers["cur_kill_streak"];
        self.stats_text setText("^1KILLSTREAK: " + self.pers["cur_kill_streak"] + " | KILLS: " + self.pers["kills"] + " | DEATHS: " + self.pers["deaths"]);

        wait 0.01;
    }
}