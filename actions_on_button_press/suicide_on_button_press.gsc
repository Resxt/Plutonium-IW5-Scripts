#include maps\mp\gametypes\_hud_util;

Init()
{
	level.suicide_button = "+actionslot 7";

	DisplayButtonsText();

	level thread OnPlayerConnected();
}

OnPlayerConnected()
{
    for(;;)
    {
		level waittill("connected", player);

		player thread OnSuicideButtonPressed(level.suicide_button);
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
}

Debug(text)
{
	print(text);
}