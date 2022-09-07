this.special_perk <- {
	m = {
		PerkID = null,
		Chance = null,
		ChanceFunction = null,
		Tier = null,
		FlavorText = null
	},
	function create()
	{
	}

    function init( _chance, _tier, _perkID, _flavorText, _chanceFunction = null )
	{
		this.setChance(_chance);
		this.setTier(_tier);
		this.setPerkID(_perkID);
		this.setFlavorText(_flavorText);
		if (_chanceFunction != null) this.setChanceFunction(_chanceFunction);

		return this;
	}

	function getChance()
	{
		return this.m.Chance;
	}

	function setChance( _chance )
	{
		::MSU.requireInteger(_chance);
		this.m.Chance = _chance;
	}

	function getTier()
	{
		return this.m.Tier;
	}

	function setTier( _tier )
	{
		::MSU.requireInteger(_tier);
		this.m.Tier = _tier;
	}

	function getPerkID()
	{
		return this.m.PerkID;
	}

	function setPerkID( _perkID )
	{
		if (::Const.Perks.findById(_perk) == null) throw ::MSU.Exception.KeyNotFound(_perk);
		this.m.PerkID = _perkID;
	}

	function setChanceFunction( _function )
	{
		::MSU.requireFunction(_function);
		this.m.ChanceFunction = _function;
	}

	function getFlavorText()
	{
		return this.m.FlavorText;
	}

	function setFlavorText( _flavorText )
	{
		::MSU.requireString(_flavorText);
		this.m.FlavorText = _flavorText;
	}

	function calculateChance( _perkTree )
	{
		local chance = this.m.Chance;

		if (this.m.PerkID in _perkTree.getBackground().m.PerkTreeMultipliers)
		{
			chance *= _perkTree.getBackground().m.PerkTreeMultipliers[this.m.PerkID];
		}

		if (this.m.ChanceFunction != null) chance *= this.m.ChanceFunction(_perkTree);

		if (_perkTree.m.Traits != null)
		{
			foreach (trait in _perkTree.m.Traits)
			{
				if (this.m.PerkID in trait.m.PerkTreeMultipliers)
				{
					chance *= trait.m.PerkTreeMultipliers[this.m.PerkID];
				}
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

		if (_perkTree.m.LocalMap != null)
		{
			foreach (category in _perkTree.m.LocalMap)
			{
				foreach (perkGroup in category)
				{
					if (this.m.PerkID in perkGroup.m.PerkTreeMultipliers)
					{
						chance *= perkGroup.m.PerkTreeMultipliers[this.m.PerkID];
					}
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
