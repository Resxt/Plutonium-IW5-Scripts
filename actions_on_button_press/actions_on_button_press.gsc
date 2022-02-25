#include maps\mp\gametypes\_hud_util;

Init()
{
	level.third_person_button = "+actionslot 6";
	level.suicide_button = "+actionslot 7";

	DisplayButtonsText();

	level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
		level waittill("connected", player);

		player thread OnSuicideButtonPressed(level.suicide_button);
		player thread OnCameraToggleButtonPressed(level.third_person_button);
		
		player thread OnPlayerSpawn(player);
    }
}

OnPlayerSpawn(player)
{
	self endon("disconnect");

	for(;;)
	{	
		self waittill("spawned_player");
		wait 1;

		player DisableDof();
	}
}

OnCameraToggleButtonPressed(button)
{
    self endon("disconnect");
    level endon("game_ended");

    self notifyOnPlayerCommand("third_person_button", button);
    while(1)
    {
		self waittill("third_person_button");

		if (GetDvar("camera_thirdPerson") == "0")
		{
			SetDynamicDvar( "camera_thirdPerson", 1);
		}
		else if (GetDvar("camera_thirdPerson") == "1")
		{
			SetDynamicDvar( "camera_thirdPerson", 0);
		}
	}
}

OnSuicideButtonPressed(button)
{
	self endon("disconnect");
	level endon("game_ended");

	self notifyOnPlayerCommand("suicide_button", button);
	while(1)
	{
		self waittill("suicide_button");

		self Suicide();
	}
}

DisplayButtonsText()
{
	suicide_text = level createServerFontString( "Objective", 0.65 );
	suicide_text setPoint( "RIGHT", "RIGHT", -4, -227.5 );
	suicide_text setText("^1Press [{" + level.suicide_button + "}] to suicide");

	third_person_text = level createServerFontString( "Objective", 0.65 );
	third_person_text setPoint( "RIGHT", "RIGHT", -4, -220 );
	third_person_text setText("^1Press [{" + level.third_person_button + "}] to toggle the camera");
}

EnableDof()
{
	self setDepthOfField( 0, 110, 512, 4096, 6, 1.8 );
}

DisableDof()
{	
	self setDepthOfField( 0, 0, 512, 512, 4, 0 );
}

Debug(text)
{
	print(text);
}