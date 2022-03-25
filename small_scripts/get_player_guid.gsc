Init()
{
    level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        Print(player.name + " GUID: " + player.guid);
        player thread OnPlayerSpawned();
    }
}

OnPlayerSpawned()
{
	self endon("disconnect");
     for(;;)
     {
		self waittill("changed_kit");
		Print(self.name + " GUID: " + self.guid);
	}
}