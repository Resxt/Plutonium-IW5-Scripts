//#include maps\mp\bots\_bot_utility; // Uncomment if using Bot Warfare

Init()
{
    level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);

        // Uncomment if using Bot Warfare
        /*if (!player IsBot())
        {
            player thread OnPlayerSpawned();
        }*/

        player thread OnPlayerSpawned(); // Remove/comment if using Bot Warfare
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");

    for(;;)
    {
        self waittill("spawned_player");

        self.pers["allow_ads"] = true;

        self thread AntiHardscope();
    }
}

AntiHardscope()
{
    self endon("disconnect");
    self endon("death");

    while (true)
    {
        if (self PlayerAds() >= 0.75)
        {
            wait 0.65;

            if (self PlayerAds() >= 0.75)
            {
                self IPrintLn("^1Hardscoping is not allowed");
                self AllowAds(false);
                self.pers["allow_ads"] = false;
            }
        }
        else if (self PlayerAds() < 0.75 && self.pers["allow_ads"] == false && self AdsButtonPressed() == false)
        {
            self.pers["allow_ads"] = true;
            self AllowAds(true);
        }

        wait 0.01;
    }
}

IsBot()
{
    //return IsDefined(self.pers["isBot"]) && self.pers["isBot"]; // Uncomment if using Bot Warfare
}