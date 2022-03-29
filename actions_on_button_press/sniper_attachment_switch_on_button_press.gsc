#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

Init()
{
	level.attachment_switch_button = "+actionslot 5";
	level.available_attachments = ["scope", "scope_silencer", "acog", "acog_silencer", "thermal", "thermal_silencer", "none", "silencer"];

	InitWeaponVariants();
		
	level thread OnPlayerConnect();

	DisplayButtonsText();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);

		player.pers["attachment_variant_name"] = "scope";
		player.pers["attachment_variant_index"] = 0;

		player thread OnAttachmentSwitchButtonPressed(level.attachment_switch_button);

        player thread OnPlayerSpawned();

		// Don't thread DisplayCurrentAttachment() on bots
        if (isDefined(player.pers["isBot"]))
        {
            if (player.pers["isBot"])
            {
                continue; // skip
            }
        }

		player thread DisplayCurrentAttachment();
    }
}

OnPlayerSpawned()
{
	self endon("disconnect");
     for(;;)
     {
		self waittill("changed_kit");

		current_weapon = self GetCurrentWeapon();

		// Whenever the player spawns check if his weapon is a sniper we want and replace his weapon with the attachment he asked for
		if (IsValidWeapon(current_weapon))
		{
			ReplaceWeapon(level.snipers_variants[current_weapon][self.pers["attachment_variant_name"]]);
		}
	}
}

DisplayButtonsText()
{
	attachment_switch_text = level createServerFontString( "Objective", 0.65 );
	attachment_switch_text setPoint( "RIGHT", "RIGHT", -4, -227.5 );
	attachment_switch_text setText("^1Press [{" + level.attachment_switch_button + "}] to switch attachment");
}

DisplayCurrentAttachment()
{
	self endon ("disconnect");
    level endon("game_ended");

	self.attachment_text = createFontString( "Objective", 0.65 );
    self.attachment_text setPoint( "RIGHT", "RIGHT", -4, -220 );
	self.current_attachment_text = "";

	while(true)
    {
		if (IsDefined(self.pers["attachment_variant_name"]))
		{
			self.new_attachment_text = "^1Current attachement: " + self.pers["attachment_variant_name"];

			// Only update when necessary, setText() is an expensive function
			if (self.current_attachment_text != self.new_attachment_text)
			{
				self.current_attachment_text = self.new_attachment_text;
				self.attachment_text setText(self.new_attachment_text);
			}
		}

        wait 0.01;
    }
}

OnAttachmentSwitchButtonPressed(button)
{
	self endon("disconnect");
	level endon("game_ended");

	self notifyOnPlayerCommand("attachment_switch_button", button);
	while(1)
	{
		self waittill("attachment_switch_button");

		if (self.pers["attachment_variant_index"] < level.available_attachments.size - 1)
		{
			self.pers["attachment_variant_index"] = self.pers["attachment_variant_index"] + 1;
		}
		else
		{
			self.pers["attachment_variant_index"] = 0;
		}
		
		self.pers["attachment_variant_name"] = level.available_attachments[self.pers["attachment_variant_index"]];

		// Here we give the weapon right when the player ask for a new attachement. 
		// If you don't want that remove this line and the new weapon will only be given on next spawn
		if (IsDefined(self.primaryWeapon))
		{
			ReplaceWeapon(level.snipers_variants[self.primaryWeapon][self.pers["attachment_variant_name"]]);
		}
	} 
}

IsValidWeapon(weapon)
{
	switch (weapon)
	{
		case "iw5_l96a1_mp_l96a1scope":
		case "iw5_msr_mp_msrscope":
		case "iw5_rsass_mp_rsassscope":
		return true;
	}

	return false;
}

ReplaceWeapon(new_weapon)
{
	secondary_weapon = self.secondaryWeapon;
	new_weapon = new_weapon + "_camo11"; // Change/remove this line to change the camo or have none

	self TakeAllWeapons();
	self GiveWeapon(new_weapon);
	self GiveWeapon(secondary_weapon); // Re-give secondary weapon because TakeAllWeapons() removes it
	self SetSpawnWeapon(secondary_weapon); // This ensures we don't have the animation when switching to the secondary weapon
	self SetSpawnWeapon(new_weapon); // This gives the weapon without playing the animation

	GiveLethalAndTactical();
}

// TakeAllWeapons() removes lethal and tactical as well so we give default items after calling it
GiveLethalAndTactical()
{
	self GiveWeapon("throwingknife_mp"); // Found in dsr files
	self GiveWeapon("flare_mp"); // Tactical insertion - found in common_mp.ff
}

// For each weapon we want we declare an array with every possible value as key, example: l188a["scope"] and then we put the full weapon code as the value
// Then once that array has been filled with all possible values we add it to the level.snipers_variants array
// This could be optimized by having a generic function that builds those arrays by passing the base weapon name (example: iw5_l96a1) as parameter but this was enough for my use case
InitWeaponVariants()
{
	level.snipers_variants = [];

	l118a = [];
	l118a["scope"] = "iw5_l96a1_mp_l96a1scope";
	l118a["scope_silencer"] = "iw5_l96a1_mp_l96a1scope_silencer03";
	l118a["acog"] = "iw5_l96a1_mp_acog";
	l118a["acog_silencer"] = "iw5_l96a1_mp_acog_silencer03";
	l118a["thermal"] = "iw5_l96a1_mp_thermal";
	l118a["thermal_silencer"] = "iw5_l96a1_mp_silencer03_thermal";
	l118a["none"] = "iw5_l96a1_mp";
	l118a["silencer"] = "iw5_l96a1_mp_silencer03";
	level.snipers_variants["iw5_l96a1_mp_l96a1scope"] = l118a;

	msr = [];
	msr["scope"] = "iw5_msr_mp_msrscope";
	msr["scope_silencer"] = "iw5_msr_mp_msrscope_silencer03";
	msr["acog"] = "iw5_msr_mp_acog";
	msr["acog_silencer"] = "iw5_msr_mp_acog_silencer03";
	msr["thermal"] = "iw5_msr_mp_thermal";
	msr["thermal_silencer"] = "iw5_msr_mp_silencer03_thermal";
	msr["none"] = "iw5_msr_mp";
	msr["silencer"] = "iw5_msr_mp_silencer03";
	level.snipers_variants["iw5_msr_mp_msrscope"] = msr;

	intervention = [];
	intervention["scope"] = "iw5_cheytac_mp_cheytacscope";
	intervention["scope_silencer"] = "iw5_cheytac_mp_cheytacscope_silencer03";
	intervention["acog"] = "iw5_cheytac_mp_acog";
	intervention["acog_silencer"] = "iw5_cheytac_mp_acog_silencer03";
	intervention["thermal"] = "iw5_cheytac_mp_thermal";
	intervention["thermal_silencer"] = "iw5_cheytac_mp_silencer03_thermal";
	intervention["none"] = "iw5_cheytac_mp";
	intervention["silencer"] = "iw5_cheytac_mp_silencer03";
	level.snipers_variants["iw5_rsass_mp_rsassscope"] = intervention;
}