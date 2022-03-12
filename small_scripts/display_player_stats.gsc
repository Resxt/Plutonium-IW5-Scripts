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
				continue; // skip
			}
		}

        player thread DisplayPlayerKillstreak();
    }
}	


DisplayPlayerKillstreak()
{
    self endon ("disconnect");
    level endon("game_ended");

    self.killstreak_text = createFontString( "Objective", 0.65 );
    self.killstreak_text setPoint( "CENTER", "TOP", "CENTER", 7.5 );
    self.killstreak_text.label = &"^1 | KILLSTREAK: ";

    self.kills_text = createFontString( "Objective", 0.65 );
    self.kills_text setPoint( -49, "TOP", -49, 7.5 );
    self.kills_text.label = &"^1KILLS: ";

    self.deaths_text = createFontString( "Objective", 0.65 );
    self.deaths_text setPoint( 56.5, "TOP", 56.5, 7.5 );
    self.deaths_text.label = &"^1 | DEATHS: ";

    while(true)
    {
        if(self.playerstreak != self.pers["cur_kill_streak"])
        {
            self.playerstreak = self.pers["cur_kill_streak"];
            self.killstreak_text setValue(self.pers["cur_kill_streak"]);
        }

        self.kills_text setValue(self.pers["kills"]);
        self.deaths_text setValue(self.pers["deaths"]);

        wait 0.01;
    }
}