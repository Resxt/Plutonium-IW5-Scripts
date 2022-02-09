#include maps\mp\killstreaks\_nuke;

main()
{
	replacefunc(maps\mp\killstreaks\_nuke::nukeVision, ::disableNukeVision); 
	replacefunc(maps\mp\killstreaks\_nuke::nukeSlowMo, ::disableNukeSlowMo);
	replacefunc(maps\mp\killstreaks\_nuke::nukeEffects, ::disableNukeEffects);
}

disableNukeVision()
{

}

disableNukeSlowMo()
{

}

disableNukeEffects()
{
	level endon( "nuke_cancelled" );
	setdvar( "ui_bomb_timer", 0 );
}