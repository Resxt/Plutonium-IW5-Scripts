#include maps\mp\killstreaks\_nuke;

main()
{
	replacefunc(maps\mp\killstreaks\_nuke::nukeVision, ::disableNukeVision); 
	replacefunc(maps\mp\killstreaks\_nuke::nukeEffects, ::disableNukeEffects);
}

disableNukeVision()
{

}

disableNukeEffects()
{
	level endon( "nuke_cancelled" );
	setdvar( "ui_bomb_timer", 0 );
	
	foreach ( var_1 in level.players )
	{
		var_2 = anglestoforward( var_1.angles );
		var_2 = ( var_2[0], var_2[1], 0 );
        	var_2 = vectornormalize( var_2 );
        	var_3 = 5000;
        	var_4 = spawn( "script_model", var_1.origin + var_2 * var_3 );
        	var_4 setmodel( "tag_origin" );
        	var_4.angles = ( 0, var_1.angles[1] + 180, 90 );
        	var_4 thread nukeEffect( var_1 );
    	}
}