#include scripts\chat_commands;

Init()
{
    CreateCommand(level.commands_servers_ports, "giveweapon", "function", ::GiveWeaponCommand);
    CreateCommand(level.commands_servers_ports, "givekillstreak", "function", ::GiveKillstreakCommand);
    CreateCommand(level.commands_servers_ports, "givecamo", "function", ::GiveCamoCommand);
}



/* Command section */

GiveWeaponCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = GivePlayerWeapon(args[0], args[1], true, true);

    if (IsDefined(error))
    {
        return error;
    }
}

GiveKillstreakCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = GivePlayerKillstreak(args[0], args[1]);

    if (IsDefined(error))
    {
        return error;
    }
}

GiveCamoCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = GivePlayerCamo(args[0], args[1], true);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

GivePlayerWeapon(targetedPlayerName, weaponName, takeCurrentWeapon, playSwitchAnimation)
{
    player = FindPlayerByName(targetedPlayerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(targetedPlayerName);
    }

    if (IsDefined(takeCurrentWeapon) && takeCurrentWeapon)
    {
        player TakeWeapon(player GetCurrentWeapon());
    }

    player GiveWeapon(weaponName);
    
    if (IsDefined(playSwitchAnimation) && playSwitchAnimation)
    {
        player SwitchToWeapon(weaponName);
    }
    else
    {
        player SetSpawnWeapon(weaponName);
    }
}

GivePlayerKillstreak(targetedPlayerName, killstreakName)
{
    player = FindPlayerByName(targetedPlayerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(targetedPlayerName);
    }

    player maps\mp\killstreaks\_killstreaks::giveKillstreak(killstreakName, false);
}

GivePlayerCamo(targetedPlayerName, camoName, playSwitchAnimation)
{
    player = FindPlayerByName(targetedPlayerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(targetedPlayerName);
    }

    finalCamoName = GetCamoNameFromNameOrIndex(camoName);

    if (!IsDefined(finalCamoName))
    {
        return CamoDoesNotExistError(camoName);
    }

    foreach (weapon in player GetWeaponsList("primary"))
    {
        if (maps\mp\_utility::iscacprimaryweapon(weapon) && !IsSubStr(weapon, "alt_iw5"))
        {
            player TakeWeapon(weapon);

            finalWeaponName = GetWeaponNameWithoutCamo(weapon) + finalCamoName;

            player GiveWeapon(finalWeaponName);

            if (IsDefined(playSwitchAnimation) && playSwitchAnimation)
            {
                player SwitchToWeapon(finalWeaponname);
            }
            else
            {
                player SetSpawnWeapon(finalWeaponname);
            }
        }
    }
}