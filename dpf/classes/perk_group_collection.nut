this.perk_group_collection <- {
	m = {
		ID = "pgc.uninitiatlized",
		Name = "Uninitialized perk group collection",
		OrderOfAssignment = 10,
		Min = 1,
		TooltipPrefix = "Has perk groups:"
		Groups = []
	},
	function create()
	{
	}

	function getName()
	{
		return this.m.Name;
	}
	function getID()
	{
		return this.m.ID;
	}

	function getGroups()
	{
		return this.m.Groups;
	}

	function getMin()
	{
		return this.m.Min;
	}

	function getTooltipPrefix()
	{
		return this.m.TooltipPrefix;
	}

	function getOrderOfAssignment()
	{
		return this.m.OrderOfAssignment;
	}

	function getSpecialMultipliers( _perkTree )
	{
		return {};
	}

	function getRandomGroup( _exclude = null )
	{
		if (_exclude != null)
		{
			::MSU.requireArray(_exclude);
			return ::MSU.Array.rand(this.m.Groups.filter(@(idx, groupID) _exclude.find(groupID) == null));
		}

		return ::MSU.Array.rand(this.m.Groups);
	}

	function getRandomPerk( _exclude = null )
	{
		return ::DPF.PerkGroups.findById(this.getRandomGroup()).getRandomPerk(null, _exclude);
	}
};
