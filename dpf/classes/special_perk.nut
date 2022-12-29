this.special_perk <- {
	m = {
		PerkID = null,
		Chance = null,
		Tier = null,
		FlavorText = null
	},
	function create()
	{
	}

	function getChance()
	{
		return this.m.Chance;
	}

	function getMultiplier( _perkTree )
	{
		return 1.0;
	}

	function getTier()
	{
		return this.m.Tier;
	}

	function getPerkID()
	{
		return this.m.PerkID;
	}

	function getFlavorText()
	{
		return this.m.FlavorText;
	}

	function calculateChance( _perkTree )
	{
		local chance = this.m.Chance;

		if (this.m.PerkID in _perkTree.getBackground().m.PerkTreeMultipliers)
		{
			chance *= _perkTree.getBackground().m.PerkTreeMultipliers[this.m.PerkID];
		}

		if (this.m.ChanceFunction != null) chance *= this.getMultiplier(_perkTree);

		foreach (trait in _perkTree.getBackground().getContainer().getSkillsByFunction(@(skill) skill.m.Type == ::Const.SkillType.Trait))
		{
			if (this.m.PerkID in trait.m.PerkTreeMultipliers)
			{
				chance *= trait.m.PerkTreeMultipliers[this.m.PerkID];
			}
		}

		if (_perkTree.getActor().getTalents().len() > 0)
		{
			for (local attribute = 0; attribute < ::Const.Attributes.COUNT; attribute++)
			{
				if (_perkTree.getActor().getTalents()[attribute] == 0) continue;

				foreach (id, mult in ::DPF.Perks.TalentMultipliers.findByAttribute(attribute))
				{
					chance *= mult * _perkTree.getActor().getTalents()[attribute];
				}
			}
		}

		if (_perkTree.m.Exclude != null)
		{
			foreach (perkGroupID in _perkTree.m.Exclude)
			{
				local perkGroup = ::DPF.Perks.PerkGroups.findById(perkGroupID);
				if (this.m.PerkID in perkGroup.m.PerkTreeMultipliers)
				{
					chance *= perkGroup.m.PerkTreeMultipliers[this.m.PerkID];
				}
			}
		}

		return chance;
	}

	function roll( _perkTree )
	{
		local chance = this.calculateChance(_perkTree);

		if (chance < 0 || ::Math.rand(1, 100) <= chance) return { PerkID = this.m.PerkID, Tier = this.m.Tier };

		return null;
	}
};
