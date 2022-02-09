init()
{
    level.callbackplayerdamagestub = level.callbackplayerdamage;
    level.callbackplayerdamage = ::cancelDamage;
}

cancelDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if (eAttacker.name == self.name && sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || eAttacker.name == self.name && sMeansOfDeath == "MOD_GRENADE_SPLASH" || eAttacker.name == self.name && sMeansOfDeath == "MOD_EXPLOSIVE")
	{
	    iDamage = 0;
	}
		
	self [[level.callbackplayerdamagestub]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}