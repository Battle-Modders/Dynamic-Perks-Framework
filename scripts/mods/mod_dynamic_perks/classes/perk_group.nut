::DynamicPerks.Class.PerkGroup <- class
{
	ID = null;
	Name = null;
	Description = null;
	Icon = null;
	FlavorText = null;
	PerkTreeMultipliers = null;
	Trees = null;

	DefaultOptions = null;

	constructor( _options )
	{
		::MSU.requireTable(_options);
		this.__initDefaultOptions();

		foreach (key, value in _options)
		{
			if (!(key in this.DefaultOptions)) throw format("invalid parameter \'%s\'", key);
			this.DefaultOptions[key] = value;
		}

		foreach (key, value in this.DefaultOptions)
		{
			this[key] = value;
		}

		this.DefaultOptions = null;
	}

	function __initDefaultOptions()
	{
		this.DefaultOptions = {
			ID = "",
			Name = "",
			Description = "",
			Icon = "",
			FlavorText = [""], // TODO: Should it be named FlavorTexts ?
			PerkTreeMultipliers = {},
			Trees = {
				"default": []
			}
		};
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
		return this.ID;
	}

	function getName()
	{
		return this.Name;
	}

	function setName( _name )
	{
		::MSU.requireString(_name);
		this.Name = _name;
	}

	function getDescription()
	{
		return this.Description;
	}

	function getIcon()
	{
		return this.Icon;
	}

	function getFlavorText()
	{
		return this.FlavorText;
	}

	function setFlavorText( _flavorText )
	{
		::MSU.requireArray(_flavorText);
		foreach (text in _flavorText)
		{
			::MSU.requireString(text);
		}
		this.FlavorText = _flavorText;
	}

	function addFlavorText( _flavorText )
	{
		switch (typeof _flavorText)
		{
			case "string":
				this.FlavorText.push(_flavorText);
				break;

			case "array":
				foreach (text in _flavorText)
				{
					::MSU.requireString(text);
				}
				this.FlavorText.extend(_flavorText);
				break;

			default:
				throw ::MSU.Exception.InvalidType(_flavorText);
		}
	}

	function getTrees()
	{
		return this.Trees;
	}

	function getTree( _id = "default" )
	{
		return this.Trees[_id];
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

		this.Trees[_id] <- _tree;
	}

	function toUIData()
	{
		return {
			ID = this.getID(),
			Name = this.getName(),
			Description = this.getDescription(),
			Icon = this.getIcon()
		}
	}

	function getRandomTree()
	{
		return ::MSU.Table.randValue(this.Trees);
	}

	function getPerkTreeMultipliers()
	{
		return this.PerkTreeMultipliers;
	}

	function setMultipliers( _multipliers )
	{
		::MSU.requireTable(_multipliers);
		foreach (key, mult in _multipliers)
		{
			this.__validateMultiplier(key, mult);
		}
		this.PerkTreeMultipliers = _multipliers;
	}

	function getSelfMultiplier( _perkTree )
	{
		return  1.0;
	}

	function addMultiplier( _id, _mult )
	{
		this.__validateMultiplier(_id, _mult);
		if (_id in this.PerkTreeMultipliers)
		{
			::logWarning("The perk group " + this.getID() + " already contains a multiplier of " + this.PerkTreeMultipliers[_id] + " for " + _id + ". Overwriting it with " + _mult);
		}

		this.PerkTreeMultipliers[_id] <- _mult;
	}

	function removeMultiplier( _id )
	{
		if (::Const.Perks.findById(_id) == null || ::DynamicPerks.PerkGroups.findById(_id) == null)
		{
			::logError("_id must be a valid perk ID or perk group ID.");
			throw ::MSU.Exception.InvalidValue(_id);
		}

		if (_id in this.PerkTreeMultipliers)
		{
			delete this.PerkTreeMultipliers[_id];
		}
	}

	function __validateMultiplier( _id, _mult )
	{
		::MSU.requireString(_id);
		::MSU.requireOneFromTypes(["integer", "float"], _mult);

		if (::Const.Perks.findById(_id) == null || ::DynamicPerks.PerkGroups.findById(_id) == null)
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
		foreach (row in this.Tree)
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

		this.Tree[_tier-1].push(_id);
	}

	function removePerk( _id )
	{
		foreach (row in this.Tree)
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
			foreach (perk in this.Tree[tier-1])
			{
				if (_exclude == null || _exclude.find(perk) == null) perks.push(perk);
			}
		}
		else
		{
			foreach (row in this.Tree)
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
