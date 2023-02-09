::DynamicPerks.Const <- {
	DefaultPerkTier = 1,	// A brother that has never spent a perk point has this PerkTier (e.g. after resetting the tree or freshly hiring them)
};

::DynamicPerks.Perks <- {
	function addPerks( _perks )
	{
		foreach (perk in _perks)
		{
			::Const.Perks.LookupMap[perk.ID] <- perk;
		}
	}
};

::DynamicPerks.PerkGroupCategories <- {
	Ordered = [],
	LookupMap = {},

	// returns a table
	function getAll()
	{
		return this.LookupMap;
	}

	// returns an array
	function getOrdered()
	{
		this.sort();
		return this.Ordered;
	}

	function findById( _id )
	{
		if (_id in this.LookupMap) return this.LookupMap[_id];
	}

	function sort()
	{
		this.Ordered.sort(@(collection1, collection2) collection1.m.OrderOfAssignment <=> collection2.m.OrderOfAssignment);
	}

	function printOrderToLog()
	{
		local text = "";
		foreach (collection in this.Ordered) text += collection.getID() + ", ";
		::logInfo(text.slice(0, -2));
	}

	function add( _collection )
	{
		if (this.findById(_collection.getID()) != null) throw ::MSU.Exception.DuplicateKey(_collection.getID());

		this.LookupMap[_collection.getID()] <- _collection;
		this.Ordered.push(_collection);
	}

	function remove( _id )
	{
		if (this.findById(_id) == null)
		{
			::logError("::DynamicPerks.PerkGroupCategories.remove -- no collection with ID \'" + _id + "\'");
			return null;
		}

		delete this.LookupMap[_id];
		return this.Ordered.remove(this.Ordered.find(_id));
	}

	function removeAll()
	{
		this.LookupMap.clear();
		this.Ordered.clear();
	}
}

::DynamicPerks.PerkGroups <- {
	LookupMap = {},

	function getAll()
	{
		return this.LookupMap;
	}

	function findById( _id )
	{
		if (_id in this.LookupMap) return this.LookupMap[_id];
	}

	function getByType( _filter )
	{
		_filter = split(_filter, "/").top();
		switch (_filter)
		{
			case "perk_group":
				return ::MSU.Table.filter(this.LookupMap, @(_, value) value.ClassName == _filter);

			default:
				return ::MSU.Table.filter(this.LookupMap, @(_, value) value.SuperName == _filter);
		}
	}

	function add( _perkGroup )
	{
		if (_perkGroup.getID() in this.LookupMap) throw ::MSU.Exception.DuplicateKey(_perkGroup.getID());
		this.LookupMap[_perkGroup.getID()] <- _perkGroup;
	}

	function remove( _id )
	{
		if (_id in this.LookupMap) delete this.LookupMap[_id];
	}

	function removeAll()
	{
		this.LookupMap.clear();
	}
};

::DynamicPerks.TalentMultipliers <- {
	Multipliers = {},

	function getAll()
	{
		return this.Multipliers;
	}

	function findByAttribute( _attribute )
	{
		if (_attribute in this.Multipliers) return this.Multipliers[_attribute];
	}

	function add( _attribute, _id, _multiplier )
	{
		if (!(_attribute in this.Multipliers)) this.Multipliers[_attribute] <- {};
		this.Multipliers[_attribute][_id] <- _multiplier;
	}

	function remove( _attribute, _id )
	{
		if ((_attribute in this.Multipliers) && (_id in this.Multipliers[_attribute])) delete this.Multipliers[_attribute][_id];
	}

	function removeAllForAttribute( _attribute )
	{
		if (_attribute in this.Multipliers) delete this.Multipliers[_attribute];
	}

	function removeAll()
	{
		this.Multipliers.clear();
	}
};

foreach (attribute in ::Const.Attributes)
{
	if (attribute != ::Const.Attributes.COUNT) ::DynamicPerks.TalentMultipliers.Multipliers[attribute] <- {};
}

::DynamicPerks.DefaultPerkTreeTemplate <- array(::Const.Perks.Perks.len());

foreach (i, row in ::Const.Perks.Perks)
{
	::DynamicPerks.DefaultPerkTreeTemplate[i] = array(row.len());
	foreach (j, perk in row)
	{
		::DynamicPerks.DefaultPerkTreeTemplate[i][j] = perk.ID;
	}
}

::DynamicPerks.DefaultPerkTree <- null;
::DynamicPerks.getDefaultPerkTree <- function()
{
	if (this.DefaultPerkTree == null)
	{
		this.DefaultPerkTree = ::new(::DynamicPerks.Class.PerkTree).init({Template = ::DynamicPerks.DefaultPerkTreeTemplate})
		this.DefaultPerkTree.build();
	}

	return this.DefaultPerkTree;
}

::DynamicPerks.addPerkGroupToTooltips <- function( _perkID = null, _groups = null )
{
	local map = {};

	foreach (group in ::DynamicPerks.PerkGroups.getAll())
	{
		foreach (row in group.getTree())
		{
			foreach (perkID in row)
			{
				if (_perkID == null || perkID == _perkID)
				{
					if (!(perkID in map))
					{
						map[perkID] <- [];
					}
					map[perkID].push(group.getName());
				}
			}

		}
	}

	foreach (perkID, groups in map)
	{
		groups = _groups == null ? groups : _groups;

		local pre = "[color=#0b0084]From the ";
		local mid = "";
		local ap = "perk group[/color]";

		local perk = ::Const.Perks.findById(perkID);
		local desc = perk.Tooltip;

		if (groups.len() == 1)
		{
			mid += groups[0] + " ";
		}
		else
		{
			for (local i = 0; i < groups.len() - 2; i++)
			{
				 mid += groups[i] + ", ";
			}
			mid += groups[groups.len()-2] + " or ";
			mid += groups[groups.len()-1] + " ";
			ap = "perk groups[/color]";
		}

		if (desc.find(pre) == null)
		{
			perk.Tooltip += "\n\n" + pre + mid + ap;
		}
		else
		{
			local strArray = split(desc, "[");

			strArray.pop();
			strArray.apply(@(a) a += "[" );

			strArray[strArray.len()-1] = "color=#0b0084]From the " + mid + ap;

			if (strArray[0].find("color=") != null)
			{
				strArray[0] = "[" + strArray[0];
			}

			local ret = "";
			foreach (s in strArray)
			{
				ret += s;
			}

			if (ret.find("\n\n" + pre) == null)
			{
				local prefix = ret.find("\n" + pre) == null ? "\n\n" : "\n";
				ret = ::MSU.String.replace(ret, pre, prefix + pre);
			}

			perk.Tooltip += text;
		}
	}
}
