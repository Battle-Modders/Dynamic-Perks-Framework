::DPF.Class <- {
	PerkGroup = "dpf/classes/perk_group",
	PerkGroupCollection = "dpf/classes/perk_group_collection",
	PerkTree = "dpf/classes/perk_tree",
	SpecialPerk = "dpf/classes/special_perk",
	PerkGroupWithChance = "dpf/classes/perk_group_with_chance"
};

::DPF.Const <- {
	DefaultPerkTier = 1,	// A brother that has never spent a perk point has this PerkTier (e.g. after resetting the tree or freshly hiring them)
	PerkTree <- {
		PrepareBuildFunctions <- [
		"addFromDynamicMap",
		"addMins",
		"addSpecialPerks"
		],
		MultiplierFunctions = [
			"addBackgroundMultipliers",
			"addPerkGroupMultipliers",
			"addItemMultipliers",
			"addTalentMultipliers",
			"addTraitMultipliers"
		]
	}
};

::DPF.Perks <- {};

::DPF.Perks.addPerks <- function( _perks )
{
	foreach (perk in _perks)
	{
		::Const.Perks.LookupMap[perk.ID] <- perk;
	}
}

::DPF.PerkTooltipEntityID <- null;
local findById = ::Const.Perks.findById;
::Const.Perks.findById = function( _id )
{
	if (::DPF.PerkTooltipEntityID != null)
	{
		return ::Tactical.getEntityByID(::DPF.PerkTooltipEntityID).getBackground().getPerkTree().getPerk(_id);
	}

	return findById(_id);
}

::DPF.Perks.PerkGroupCategories <- {
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
			::logError("::DPF.Perks.PerkGroupCategories.remove -- no collection with ID \'" + _id + "\'");
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

::DPF.Perks.PerkGroups <- {
	LookupMap = {},

	function getAll()
	{
		return this.LookupMap;
	}

	function findById( _id )
	{
		if (_id in this.LookupMap) return this.LookupMap[_id];
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

::DPF.Perks.SpecialPerks <- {
	LookupMap = {},

	function getAll()
	{
		return this.LookupMap;
	}

	function findById( _id )
	{
		if (_id in this.LookupMap) return this.LookupMap[_id];
	}

	function add( _specialPerk )
	{
		if (_specialPerk.getPerkID() in this.LookupMap) throw ::MSU.Exception.DuplicateKey(_specialPerk.getPerkID());
		this.LookupMap[_specialPerk.getID()] <- _specialPerk;
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

::DPF.Perks.TalentMultipliers <- {
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
	if (attribute != ::Const.Attributes.COUNT) ::DPF.Perks.TalentMultipliers.Multipliers[attribute] <- {};
}

::DPF.Perks.DefaultPerkTreeTemplate <- array(::Const.Perks.Perks.len());

foreach (i, row in ::Const.Perks.Perks)
{
	::DPF.Perks.DefaultPerkTreeTemplate[i] = array(row.len());
	foreach (j, perk in row)
	{
		::DPF.Perks.DefaultPerkTreeTemplate[i][j] = perk.ID;
	}
}

::DPF.Perks.DefaultPerkTree <- ::new(::DPF.Class.PerkTree).init(::DPF.Perks.DefaultPerkTreeTemplate);
::DPF.Perks.DefaultPerkTree.build();

::DPF.Perks.PerkGroups.add(::new(::DPF.Class.PerkGroup).init("DPF_RandomPerkGroup", "Random", ["Random perk group"], []));
::DPF.Perks.PerkGroups.add(::new(::DPF.Class.PerkGroup).init("DPF_NoPerkGroup", "NoPerkGroup", ["No perk group"], []));

::DPF.Perks.addPerkGroupToTooltips <- function( _perkID = null, _groups = null )
{
	local map = {};

	foreach (group in ::DPF.Perks.PerkGroups.getAll())
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
