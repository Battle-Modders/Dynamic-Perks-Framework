this.perk_group <- {
	m = {
		ID = "not_initialized",
		Name = "Not initialized Perk Group",
		FlavorText = ["Not initialized perk group"], // TODO: Should it be named FlavorTexts ?
		Multipliers = {},
		Tree = [ [], [], [], [], [], [], [], [], [], [], [] ] // length 11
	},
	function create()
	{
	}

	function init( _id, _name, _flavorText, _tree, _multipliers = null )
	{
		::MSU.requireString(_id);

		this.m.ID = _id;
		this.setName(_name);
		this.setFlavorText(_flavorText);

		if (_multipliers != null) this.setMultipliers(_multipliers);

		return this;
	}

	function getID()
	{
		return this.m.ID;
	}

	function getName()
	{
		return this.m.Name;
	}

	function setName( _name )
	{
		::MSU.requireString(_name);
		this.m.Name = _name;
	}

	function getFlavorText()
	{
		return this.m.FlavorText;
	}

	function setFlavorText( _flavorText )
	{
		::MSU.requireArray(_flavorText);
		foreach (text in _flavorText)
		{
			::MSU.requireString(text);
		}
		this.m.FlavorText = _flavorText;
	}

	function addFlavorText( _flavorText )
	{
		switch (typeof _flavorText)
		{
			case "string":
				this.m.FlavorText.push(_flavorText);
				break;

			case "array":
				foreach (text in _flavorText)
				{
					::MSU.requireString(text);
				}
				this.m.FlavorText.extend(_flavorText);
				break;

			default:
				throw ::MSU.Exception.InvalidType(_flavorText);
		}
	}

	function getTree()
	{
		return this.m.Tree;
	}

	function setTree( _tree )
	{
		::MSU.requireArray(_tree);
		if (_tree.len() < 7)
		{
			::logError("The length of _tree must be 7");
			::MSU.Exception.InvalidValue(_tree);
		}
		foreach (row in _tree)
		{
			::MSU.requireArray(row);
			foreach (perk in row)
			{
				if (::Const.Perks.findById(perk) == null) throw ::MSU.Exception.InvalidValue(perk);
			}
		}

		this.m.Tree = _tree;
	}

	function getSelfMultiplier()
	{
		return this.getID() in this.m.Multipliers ? this.m.Multipliers[this.getID()] : 1.0;
	}

	function getMultipliers()
	{
		return this.m.Multipliers;
	}

	function setMultipliers( _multipliers )
	{
		::MSU.requireTable(_multipliers);
		foreach (key, mult in _multipliers)
		{
			this.__validateMultiplier(key, mult);
		}
		this.m.Multipliers = _multipliers;
	}

	function getPerkGroupMultipliers()
	{
		local ret = {};
		foreach (id, mult in this.m.Multipliers)
		{
			if (::Const.Perks.PerkGroup.findById(id) != null) ret[id] <- mult;
		}

		return ret;
	}

	function getSpecialPerkMultipliers()
	{
		local ret = {};
		foreach (id, mult in this.m.Multipliers)
		{
			if (::Const.Perks.SpecialPerks.findById(id) != null) ret[id] <- mult;
		}

		return ret;
	}

	function addMultiplier( _id, _mult )
	{
		this.__validateMultiplier(_id, _mult);
		if (_id in this.m.Multipliers)
		{
			::logWarning("The perk group " + this.getID() + " already contains a multiplier of " + this.m.Multipliers[_id] + " for " + _id + ". Overwriting it with " + _mult);
		}

		this.m.Multipliers[_id] <- _mult;
	}

	function removeMultiplier( _id )
	{
		if (::Const.Perks.findById(_id) == null || ::Const.Perks.PerkGroup.findById(_id) == null)
		{
			::logError("_id must be a valid perk ID or perk group ID.");
			throw ::MSU.Exception.InvalidValue(_id);
		}

		if (_id in this.m.Multipliers)
		{
			delete this.m.Multipliers[_id];
		}
	}

	function __validateMultiplier( _id, _mult )
	{
		::MSU.requireString(_id);
		::MSU.requireOneFromTypes(["integer", "float"], _mult);

		if (::Const.Perks.findById(_id) == null || ::Const.Perks.PerkGroup.findById(_id) == null)
		{
			::logError("The key in a multiplier must be a valid perk ID or perk group ID.");
			throw ::MSU.Exception.InvalidValue(_id);
		}
	}

	function findPerk( _perk )
	{
		foreach (row in this.m.Tree)
		{
			foreach (perk in row)
			{
				if (perk == _perk) return row;
			}
		}
	}

	function addPerk( _perk, _tier )
	{
		if (::Const.Perks.findById(_perk) == null) throw ::MSU.Exception.InvalidValue(_perk);

		local row = this.findPerk(_perk);
		if (row != null)
		{
			::logWarning("Perk " + _perk + " already exists in perk group " + this.getID() + " at tier " + (row + 1));
			return;
		}

		this.m.Tree[_tier-1].push(_perk);
	}

	function removePerk( _perk )
	{
		foreach (row in this.m.Tree)
		{
			foreach (i, perk in row)
			{
				if (perk == _perk) return row.remove(i);
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
