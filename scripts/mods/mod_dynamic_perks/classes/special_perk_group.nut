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
			local mult = skill.getPerkGroupMultiplier(this.getID(), _perkTree);
			if (mult == null)
				continue;
			if (mult < 0)
				return 100;
			chance *= mult;
		}

		foreach (perkGroupID in _perkTree.getPerkGroups())
		{
			local mult = ::DynamicPerks.PerkGroups.findById(perkGroupID).getPerkGroupMultiplier(this.getID(), _perkTree);
			if (mult == null)
				continue;
			if (mult < 0)
				return 100;
			chance *= mult;
		}

		return chance;
	}

	function roll( _perkTree )
	{
		local chance = this.calculateChance(_perkTree);
		return ::Math.rand(1, 100) <= chance;
	}
});
