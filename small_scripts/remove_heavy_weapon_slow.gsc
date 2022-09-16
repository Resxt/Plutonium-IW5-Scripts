#include maps\mp\_utility;

Init()
{
    InitRemoveHeavyWeaponSlow();
}

InitRemoveHeavyWeaponSlow()
{
    level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);

        player thread OnPlayerSpawned();
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");
    
    for(;;)
    {
        self waittill("changed_kit");

        self SetMoveSpeedScale(1);

        self thread OnPlayerWeaponSwitch();
    }
}

/*
The move speed scale is reset whenever we switch weapons so we need to re-apply it on weapon change
*/
OnPlayerWeaponSwitch()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill( "weapon_change", newWeapon );

        wait 0.05; // For some reason this is needed otherwise when you fully stop and switch weapon it won't apply

        self SetMoveSpeedScale(1);
    }
}