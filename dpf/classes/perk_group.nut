this.perk_group <- {
	m = {
		ID = "pg.uninitialized",
		Name = "Uninitialized Perk Group",
		FlavorTexts = ["Uninitialized perk group"],
		PerkTreeMultipliers = {},
		Trees = {}
	},
	function create()
	{
	}

	function getID()
	{
		return this.m.ID;
	}

	function getName()
	{
		return this.m.Name;
	}

	function getFlavorText()
	{
		return ::MSU.Array.rand(this.m.FlavorTexts);
	}

	function getTrees()
	{
		return this.m.Trees;
	}

	function getTree( _id = "default" )
	{
		return this.m.Trees[_id];
	}

	function getRandomTree()
	{
		return ::MSU.Table.randValue(this.m.Trees);
	}

	function getPerkTreeMultipliers()
	{
		return this.m.PerkTreeMultipliers;
	}

	function getSelfMultiplier()
	{
		if ("self" in this.m.PerkTreeMultipliers)
		{
			return this.m.PerkTreeMultipliers["self"];
		}

		if (this.getID() in this.m.PerkTreeMultipliers)
		{
			return this.m.PerkTreeMultipliers[this.getID()];
		}

		return  1.0;
	}

	function hasPerk( _id )
	{
		return this.findPerk(_id) != null;
	}

	function findPerk( _id )
	{
		foreach (row in this.m.Tree)
		{
			foreach (perk in row)
			{
				if (perk == _id) return row;
			}
		}
	}

	function getRandomPerk( _tier = null, _exclude = null )
	{
		local perks = [];
		if (_tier != null)
		{
			foreach (perk in this.m.Tree[tier-1])
			{
				if (_exclude == null || _exclude.find(perk) == null) perks.push(perk);
			}
		}
		else
		{
			foreach (row in this.m.Tree)
			{
				foreach (perk in row)
				{
					if (_exclude == null || _exclude.find(perk) == null) perks.push(perk);
				}
			}
		}

		return ::MSU.Array.rand(perks);
	}
};
