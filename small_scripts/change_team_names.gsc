Init()
{
    switch (GetDvar("g_gametype"))
    {
        case "infect":
            ReplaceTeamNames("^1Infected", "^2Survivors");
        break;
        case "dm":
            ReplaceTeamNames("^1Solo", "");
        break;
        default:
            ReplaceTeamNames("^1Team #1", "^1Team #2");
        break;
    }
}

ReplaceTeamNames(axis_name, allies_name)
{
    SetDvar("g_TeamName_Axis", axis_name);
    SetDvar("g_TeamName_Allies", allies_name);
}