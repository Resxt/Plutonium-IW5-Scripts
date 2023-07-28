#include scripts\chat_commands;

Init()
{   
    CreateCommand(level.chat_commands["ports"], "balanceteams", "function", ::BalanceTeamsCommand, 3, [], ["bt"]);
}



/* Command section */

BalanceTeamsCommand(args)
{
    BalanceTeams();
}



/* Logic section */

BalanceTeams()
{
    if (!maps\mp\gametypes\_teams::getteambalance()) 
    {
        self thread TellPlayer(["Balancing teams"], 1);
        level maps\mp\gametypes\_teams::balanceteams(); 
    }
    else
    {
        self thread TellPlayer(["Teams are already balanced"], 1);
    }
}