#include maps\mp\bots\_bot_utility;

Init()
{
    InitManageBotsFill();
}

InitManageBotsFill()
{
    InitServersDvar();

    SetDvar("bots_manage_fill_kick", 1);
    
    level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for (;;)
    {
        level waittill("connected", player);

        if (!player IsBot())
        {
            TryUpdateBotsManageFill();

            player thread OnPlayerDisconnect();
        }
    }
}

OnPlayerDisconnect()
{
    self waittill("disconnect");

    TryUpdateBotsManageFill();
}

InitServersDvar()
{
    level.manage_bots_fill = [];

    level.manage_bots_fill["27017"] = "12";
}

TryUpdateBotsManageFill()
{
    wait 1;

    if (HasHumanPlayers())
    {
        if (GetDvar("bots_manage_fill") != level.manage_bots_fill[GetDvar("net_port")])
        {
            SetDvar("bots_manage_fill", level.manage_bots_fill[GetDvar("net_port")]);
        }
    }
    else
    {
        SetDvar("bots_manage_fill", 0);
    }
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}

HasHumanPlayers()
{
    foreach (player in level.players)
    {
        if (!player IsBot())
        {
            return true;
        }
    }

    return false;
}