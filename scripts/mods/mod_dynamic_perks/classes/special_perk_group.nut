this.special_perk_group <- ::inherit(::DynamicPerks.Class.PerkGroup, {
	m = {
		Chance = null
	},
	function create()
	{
		this.perk_group.create();
	}

	function getChance()
	{
		return this.m.Chance;
	}

	function getMultiplier( _perkTree )
	{
		return 1.0;
	}

	function calculateChance( _perkTree )
	{
		local chance = this.m.Chance;

		if (chance < 0) return 100;

		chance *= this.getMultiplier(_perkTree);
		if (chance < 0) return 100;

		local myID = this.getID();

		foreach (skill in _perkTree.getActor().getSkills().m.Skills)
		{
			local multipliers = skill.getPerkTreeMultipliers();
			if (myID in multipliers)
			{
				local mult = multipliers[myID];
				if (chance < 0 || mult < 0) return 100;
				else chance *= mult;
			}
		}

		foreach (perkGroupID in _perkTree.getPerkGroups())
		{
			local perkGroup = ::DynamicPerks.PerkGroups.findById(perkGroupID);
			if (myID in perkGroup.m.PerkTreeMultipliers)
			{
				local mult = perkGroup.m.PerkTreeMultipliers[myID];
				if (chance < 0 || mult < 0) return 100;
				else chance *= mult;
			}
		}

		return chance;
	}

	function roll( _perkTree )
	{
		local chance = this.calculateChance(_perkTree);
		return ::Math.rand(1, 100) <= chance;
	}
});
