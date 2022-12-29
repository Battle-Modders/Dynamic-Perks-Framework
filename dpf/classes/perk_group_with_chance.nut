this.perk_group_with_chance <- ::inherit(::DPF.Class.PerkGroup, {
	m = {
		Chance = null
	},
	function create()
	{
		this[this.SuperName].create();
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
		local myID = this.getID();

		if (myID in _perkTree.getBackground().m.PerkTreeMultipliers)
		{
			local mult = _perkTree.getBackground().m.PerkTreeMultipliers[myID];
			if (chance < 0 || mult < 0) return chance;
			else chance *= mult;
		}

		chance *= this.getMultiplier(_perkTree);

		foreach (trait in _perkTree.getBackground().getContainer().getSkillsByFunction(@(skill) skill.m.Type == ::Const.SkillType.Trait))
		{
			if (myID in trait.m.PerkTreeMultipliers)
			{
				local mult = trait.m.PerkTreeMultipliers[myID];
				if (chance < 0 || mult < 0) return chance;
				else chance *= mult;
			}
		}

		if (_perkTree.getActor().getTalents().len() > 0)
		{
			for (local attribute = 0; attribute < ::Const.Attributes.COUNT; attribute++)
			{
				if (_perkTree.getActor().getTalents()[attribute] == 0) continue;

				local mults = ::DPF.Perks.TalentMultipliers.findByAttribute(attribute);
				if (myID in mults)
				{
					local mult = mults[myID];
					if (chance < 0 || mult < 0) return chance;
					else chance *= mult * _perkTree.getActor().getTalents()[attribute];
				}
			}
		}

		foreach (perkGroup in _perkTree.getPerkGroups())
		{
			if (myID in perkGroup.m.PerkTreeMultipliers)
			{
				local mult = perkGroup.m.PerkTreeMultipliers[myID];
				if (chance < 0 || mult < 0) return chance;
				else chance *= mult;
			}
		}

		return chance;
	}

	function roll( _perkTree )
	{
		local chance = this.calculateChance(_perkTree);
		return chance < 0 || ::Math.rand(1, 100) <= chance;
	}
});
