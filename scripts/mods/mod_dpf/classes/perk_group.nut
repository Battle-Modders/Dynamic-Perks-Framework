this.perk_group <- ::inherit(::MSU.BBClass.Empty, {
	m = {
		ID = "not_initialized",
		Name = "Not initialized Perk Group",
		Description = "",
		Icon = "",
		FlavorText = ["Not initialized perk group"], // TODO: Should it be named FlavorTexts ?
		PerkTreeMultipliers = {},
		Trees = {
			"default": []
		}
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
		this.setTree(_tree);

		if (_multipliers != null) this.setMultipliers(_multipliers);

		return this;
	}

	function getTooltip()
	{
		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			}
		];

		foreach (i, row in this.getTree())
		{
			local perks = [];
			foreach (j, perkID in row)
			{
				local perkDef = ::Const.Perks.findById(perkID);
				perks.push({
					id = 10,
					type = "text",
					icon = perkDef.Icon,
					text = perkDef.Name
				});
			}

			ret.push({
				id = 3 + i,
				type = "text",
				text = "Tier " + (i + 1) + ":",
				children = perks
			});
		}

		return ret;
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

	function getDescription()
	{
		return this.m.Description;
	}

	function getIcon()
	{
		return this.m.Icon;
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

	function getTrees()
	{
		return this.m.Trees;
	}

	function getTree( _id = "default" )
	{
		return this.m.Trees[_id];
	}

	function setTree( _tree, _id = "default" )
	{
		::MSU.requireArray(_tree);
		::MSU.requireString(_id);
		foreach (row in _tree)
		{
			::MSU.requireArray(row);
			foreach (perk in row)
			{
				if (::Const.Perks.findById(perk) == null) throw ::MSU.Exception.InvalidValue(perk);
			}
		}

		this.m.Trees[_id] <- _tree;
	}

	function getRandomTree()
	{
		return ::MSU.Table.randValue(this.m.Trees);
	}

	function getPerkTreeMultipliers()
	{
		return this.m.PerkTreeMultipliers;
	}

	function setMultipliers( _multipliers )
	{
		::MSU.requireTable(_multipliers);
		foreach (key, mult in _multipliers)
		{
			this.__validateMultiplier(key, mult);
		}
		this.m.PerkTreeMultipliers = _multipliers;
	}

	function getSelfMultiplier( _perkTree )
	{
		return  1.0;
	}

	function addMultiplier( _id, _mult )
	{
		this.__validateMultiplier(_id, _mult);
		if (_id in this.m.PerkTreeMultipliers)
		{
			::logWarning("The perk group " + this.getID() + " already contains a multiplier of " + this.m.PerkTreeMultipliers[_id] + " for " + _id + ". Overwriting it with " + _mult);
		}

		this.m.PerkTreeMultipliers[_id] <- _mult;
	}

	function removeMultiplier( _id )
	{
		if (::Const.Perks.findById(_id) == null || ::DPF.Perks.PerkGroups.findById(_id) == null)
		{
			::logError("_id must be a valid perk ID or perk group ID.");
			throw ::MSU.Exception.InvalidValue(_id);
		}

		if (_id in this.m.PerkTreeMultipliers)
		{
			delete this.m.PerkTreeMultipliers[_id];
		}
	}

	function __validateMultiplier( _id, _mult )
	{
		::MSU.requireString(_id);
		::MSU.requireOneFromTypes(["integer", "float"], _mult);

		if (::Const.Perks.findById(_id) == null || ::DPF.Perks.PerkGroups.findById(_id) == null)
		{
			::logError("The key in a multiplier must be a valid perk ID or perk group ID.");
			throw ::MSU.Exception.InvalidValue(_id);
		}
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

	function addPerk( _id, _tier )
	{
		if (::Const.Perks.findById(_id) == null) throw ::MSU.Exception.InvalidValue(_id);

		local row = this.findPerk(_id);
		if (row != null)
		{
			::logWarning("Perk " + _id + " already exists in perk group " + this.getID() + " at tier " + (row + 1));
			return;
		}

		this.m.Tree[_tier-1].push(_id);
	}

	function removePerk( _id )
	{
		foreach (row in this.m.Tree)
		{
			foreach (i, perk in row)
			{
				if (perk == _id) return row.remove(i);
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
});
