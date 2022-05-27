# Replace Weapon On Spawn

This can easily be modified to always give a certain weapon or only give it when the player has a certain weapon etc.  
This is useful to add ported weapons like the Intervention to your default classes until Plutonium adds the possibility to do it directly in dsr files.

## replace_rsass_with_intervention.gsc

Replace the RSASS with an Intervention (ACOG sight)

Replace the RSASS silencer with an Intervention (ACOG sight + silencer)

Gives a throwing knife and a tactical insertion in both cases

## replace_with_snipers.gsc

Replace any weapon with a bolt action sniper with the extended mags attachment.  
Can be configured to only work for bots, players or both by changing `level.rws_applies_to`.   
As of now this removes secondary weapons and grenades but the script can easily be modified to add additional checks for these and replace/remove them only if needed.  
An example that shows how to only apply the replacement if the primary isn't valid can be found in `DoWeaponCheck()`.