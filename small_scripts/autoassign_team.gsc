Init()
{
    InitTest();
}

InitTest()
{
    replacefunc(maps\mp\_utility::allowTeamChoice, ::ReplaceAllowTeamChoice);

    level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player); 

        if (!IsDefined(player.pers["autoassign_connected"]) || !player.pers["autoassign_connected"])
        {
            player.pers["autoassign_connected"] = true;

            player [[level.autoassign]]();
        }
    }
}

ReplaceAllowTeamChoice()
{   
    return false;
}