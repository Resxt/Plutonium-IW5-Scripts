#include maps\mp\_utility;

Init()
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

		GivePerks();
	}
}

GivePerks()
{
	if ( !self _hasPerk( "specialty_quickdraw" ))
	{
		self givePerk( "specialty_quickdraw", false ); // Quickdraw
		self givePerk( "specialty_fastoffhand", false ); // Quickdraw Pro
	}

	if ( !self _hasPerk( "specialty_fastreload" ))
	{
		self givePerk( "specialty_fastreload", false ); // Sleight of hand
		self givePerk( "specialty_quickswap", false ); // Sleight of hand Pro
	}
}