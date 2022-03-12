#include maps\mp\gametypes\_hud_util;

Init()
{
	level.camera_switch_vote_button = "+actionslot 6";

	DisplayButtonsText();

	level thread DisplayVoteCount();
	level thread OnPlayerConnected();
}

OnPlayerConnected()
{
    for(;;)
    {
		level waittill("connected", player);

		player.pers["camera_switch_vote"] = false;

		player thread OnCameraSwitchVoteButtonPressed(level.camera_switch_vote_button);

		player thread OnPlayerSpawned(player);
    }
}

OnPlayerSpawned(player)
{
	self endon("disconnect");

     for(;;)
     {	
		self waittill("spawned_player");

		player DisableDof();
	}
}

OnCameraSwitchVoteButtonPressed(button)
{
	self endon("disconnect");
	level endon("game_ended");

	self notifyOnPlayerCommand("camera_switch_vote_button", button);
	while(1)
	{
		self waittill("camera_switch_vote_button");
		self.pers["camera_switch_vote"] = !self.pers["camera_switch_vote"];
		if (self.pers["camera_switch_vote"])
		{
			CustomPrintLn("You voted to switch the camera");
		}
		else
		{
			CustomPrintLn("You removed your vote to switch the camera");
		}
	} 
}

DisplayButtonsText()
{
	camera_switch_vote_text = level createServerFontString( "Objective", 0.65 );
	camera_switch_vote_text setPoint( "RIGHT", "RIGHT", -4, -227.5 );
	camera_switch_vote_text setText("^1Press [{" + level.camera_switch_vote_button + "}] to toggle vote for camera switch");
}

DisplayVoteCount()
{
	level.camera_switch_vote_count_text = level createServerFontString( "Objective", 0.65 );
	level.camera_switch_vote_count_text setPoint( "RIGHT", "RIGHT", -4, -220 );

	while(true)
	{
		yes_votes = 0;
		human_players = [];

		foreach (player in level.players)
		{
			if (isDefined(player.pers["isBot"]))
			{
				if (player.pers["isBot"])
				{
					break;
				}
			}

			if (player.pers["camera_switch_vote"])
			{
				yes_votes++;
			}

			human_players[human_players.size] = player;
		}

		votes_required = 0;

		// Votes required = more than 50% of the players: 1/1 | 2/2 | 3/4 | 3/5 | 4/6 etc.
		if (human_players.size % 2 == 1)
		{	
			votes_required = (human_players.size / 2 + 0.5);
		}
		else if (human_players.size % 2 == 0)
		{
			votes_required = (human_players.size / 2 + 1);
		}

		level.camera_switch_vote_count_text setText("^1Votes to switch camera: " + yes_votes + "/" + votes_required);

		if (yes_votes >= votes_required && human_players.size > 0)
		{
			// Logic here
			setDvar( "camera_thirdPerson", !getDvarInt( "camera_thirdPerson" ) );
			
			// Mention changes to all players (if there is more than one player)
			if (human_players.size > 1)
			{
				if (getDvarInt( "camera_thirdPerson" ) == 0)
				{
					CustomPrintLn("More than half of the players voted to switch to 1st person");
				}
				else
				{
					CustomPrintLn("More than half of the players voted to switch to 3rd person");
				}
			}
			
			// Reset votes variables	
			yes_votes = 0;
			
			foreach (player in human_players)
			{
				player.pers["camera_switch_vote"] = false;
			}
		}

		wait 0.01;
	}
}

EnableDof()
{
	self setDepthOfField( 0, 110, 512, 4096, 6, 1.8 );
}

DisableDof()
{	
	self setDepthOfField( 0, 0, 512, 512, 4, 0 );
}

CustomPrintLn(text)
{
	IPrintLn("^1" + text);
}

Debug(text)
{
	print(text);
}