#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "godmode", "function", ::GodModeCommand, 3, ["default_help_one_player"], ["god"]);
}



/* Command section */

GodModeCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleGodMode(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleGodMode(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "god";

    ToggleStatus(commandName, "God Mode", player);

    if (GetStatus(commandName, player))
    {
        player DoGodMode(true);
        player thread ThreadGodMode();
    }
    else
    {
        player DoGodMode(false);
        player notify("chat_commands_god_mode_off");
    }
}

ThreadGodMode()
{
    self endon("disconnect");
    self endon("chat_commands_god_mode_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        self DoGodMode(true);
    }
}

DoGodMode(enabled)
{
    health = 99999;
    
    if (!enabled)
    {
        health = GetDvarInt("scr_player_maxhealth");
    }

    deadSilencePro = "specialty_falldamage";

    if (enabled && !self maps\mp\_utility::_hasPerk(deadSilencePro)) // if god mode is on and player doesn't have dead silence pro
    {
        self maps\mp\_utility::givePerk(deadSilencePro, false); // give dead silence pro
        self.pers["god_mode_gave_perk"] = true;
    }
    else if (!enabled && self maps\mp\_utility::_hasPerk(deadSilencePro) && self.pers["god_mode_gave_perk"]) // if god mode is off and player has dead silence pro and it was given by god mode on
    {
        self maps\mp\_utility::_unsetperk(deadSilencePro); // remove dead silence pro
        self.pers["god_mode_gave_perk"] = false;
    }

    self.maxhealth = health;
    self.health = health;
}