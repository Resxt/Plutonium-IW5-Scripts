Init()
{
    out_of_map_y = GetOutOfMapValue(GetDvar("mapname"));
    
    level thread OnPlayerConnect(out_of_map_y);
}
OnPlayerConnect(out_of_map_y)
{
    for(;;)
    {
        level waittill("connected", player);

        player thread OnPlayerSpawned(out_of_map_y);
    }
}

OnPlayerSpawned(out_of_map_y)
{
    level endon("game_ended");
    self endon("disconnect");

    for(;;)
    {
        self waittill("spawned_player");

        while (true)
        {
            if (IsDefined(self.origin[2]))
            {
                Print(self.origin[2]); // Comment this line when using on your server

                if (self.origin[2] < out_of_map_y)
                {
                    self Suicide();
                }
            }

            wait 0.01;
        }
    }
}

GetOutOfMapValue(map_name)
{
    switch (map_name)
    {
        case "mp_showdown_sh":
        return -318;

        case "mp_bog":
        return -766;

        default:
        return -999999;
    }
}