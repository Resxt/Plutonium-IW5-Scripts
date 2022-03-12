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

    kills_text_x = -49;
    kills_text_x_move = 2.5;
    self.kills_text = createFontString( "Objective", 0.65 );
    self.kills_text setPoint( kills_text_x, "TOP", kills_text_x, 7.5 );
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

        if (self.pers["kills"] >= 10 && self.kills_text.x == kills_text_x)
        {
            self.kills_text.x = self.kills_text.x - kills_text_x_move;
        }
        else if (self.pers["kills"] >= 100 && self.kills_text.x == kills_text_x - kills_text_x_move)
        {
            self.kills_text.x = self.kills_text.x - kills_text_x_move;
        }

        self.kills_text setValue(self.pers["kills"]);
        self.deaths_text setValue(self.pers["deaths"]);

        wait 0.01;
    }
}