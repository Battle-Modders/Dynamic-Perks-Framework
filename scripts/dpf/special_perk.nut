this.special_perk <- ::inherit("scripts/config/legend_dummy_bb_class", {
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
		if (_chanceFunction == null) _chanceFunction = @() this.Chance;
		else this.setChanceFunction(_chanceFunction);

		::Const.Perks.SpecialPerks.LookupMap[_perk] <- this;

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

	function roll( _player )
	{
		local chance = this.m.Chance;

		foreach (multiplier in _player.getBackground().m.SpecialPerkMultipliers)
		{
			if (multiplier[1] == this.m.PerkID)
			{
				chance *= multiplier[0];
				break;
			}
		}

		chance *= this.m.ChanceFunction(_player);

		if (_player.getBackground().getPerkTree().m.Traits != null)
		{
			foreach (trait in _player.getBackground().getPerkTree().m.Traits)
			{
				foreach (multiplier in trait.m.SpecialPerkMultipliers)
				{
					if (multiplier[1] == this.m.PerkID)
					{
						chance *= multiplier[0];
						break;
					}
				}
			}
		}

		if (_player.getBackground().getPerkTree().m.LocalMap != null)
		{
			foreach (category in _player.getBackground().getPerkTree().m.LocalMap)
			{
				foreach (perkGroup in category)
				{
					if ("SpecialPerkMultipliers" in perkGroup)
					{
						foreach (multiplier in perkGroup.SpecialPerkMultipliers)
						{
							if (multiplier[1] == this.m.PerkID)
							{
								chance *= multiplier[0];
								break;
							}
						}
					}
				}
			}
		}

		if (chance < 0 || ::Math.rand(1, 100) <= chance) return { PerkID = this.m.PerkID, Tier = this.m.Tier };

		return null;
	}
});
