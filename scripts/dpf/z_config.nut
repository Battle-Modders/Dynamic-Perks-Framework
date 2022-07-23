::Const.Perks.add <- function( _perks )
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

::Const.Perks.PerkGroupCollections <- {
	UsedForPerkTree = [],
	LookupMap = {},

	// returns a table
	function getAll()
	{
		return this.LookupMap;
	}

	// returns an array
	function getUsedForPerkTree( _used = true )
	{
		return _used ? this.UsedForPerkTree : ::MSU.Table.getValues(this.LookupMap).filter(@(idx, collection) this.UsedForPerkTree.find(collection) == null);
	}

	function findById( _id )
	{
		if (_id in this.LookupMap) return this.LookupMap[_id];
	}

	function sort()
	{
		this.UsedForPerkTree.sort(@(collection1, collection2) collection1.m.OrderOfAssignment <=> collection2.m.OrderOfAssignment);
	}

	function printOrderToLog()
	{
		local text = "";
		foreach (collection in this.UsedForPerkTree) text += collection.getID() + ", ";
		::logInfo(text.slice(0, -2));
	}

	function add( _id, _name, _tooltipPrefix = null, _min = 1, _groups = null )
	{
		if (this.findById(_id) != null) throw ::MSU.Exception.DuplicateKey(_id);
		local collection = ::new("scripts/dpf/perk_group_collection").init(_id, _name, _tooltipPrefix, _min, _groups);
		this.LookupMap[_id] <- collection;
		return collection;
	}

	function remove( _id )
	{
		local collection = this.findById(_id);

		if (collection == null)
		{
			::logWarning("::Const.Perks.PerkGroupCollections.remove -- no collection with ID \'" + _id + "\'");
			return null;
		}

		delete this.LookupMap[_id];
		if (collection.isUsedForPerkTree()) this.UsedForPerkTree.remove(this.UsedForPerkTree.find(_id));

		return collection;
	}

	function removeAll()
	{
		this.LookupMap.clear();
		this.UsedForPerkTree.clear();
	}

	function setUsedForPerkTree( _id, _used = true )
	{
		if (this.findById(_id) == null) throw ::MSU.Exception.KeyNotFound(_id);

		local collection = this.findById(_id);

		if (_used)
		{
			if (this.UsedForPerkTree.find(collection) != null) return;
			this.UsedForPerkTree.push(collection);
			this.sort();
		}
		else if (this.UsedForPerkTree.find(collection) != null)
		{
			this.UsedForPerkTree.remove(this.UsedForPerkTree.find(collection));
		}
	}

	function isUsedForPerkTree( _id )
	{
		if (this.findById(_id) == null) throw ::MSU.Exception.KeyNotFound(_id);
		return  this.UsedForPerkTree.find(collection) != null;
	}
}

::Const.Perks.PerkGroups <- {
	LookupMap = {},

	function getAll()
	{
		return this.LookupMap;
	}

	function findById( _id )
	{
		if (_id in this.LookupMap) return this.LookupMap[_id];
	}

	function add( _id, _name, _flavorText, _tree, _multipliers = null )
	{
		if (_id in this.LookupMap) throw ::MSU.Exception.DuplicateKey(_id);
		this.LookupMap[_id] <- ::new("scripts/dpf/perk_group").init(_id, _name, _flavorText, _tree, _multipliers);
		return this.LookupMap[_id];
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

::Const.Perks.SpecialPerks <- {
	LookupMap = {},

	function getAll()
	{
		return this.LookupMap;
	}

	function findById( _id )
	{
		if (_id in this.LookupMap) return this.LookupMap[_id];
	}

	function add( _chance, _tier, _perkID, _flavorText, _chanceFunction = null )
	{
		if (_perkID in this.LookupMap) throw ::MSU.Exception.DuplicateKey(_perkID);
		this.LookupMap[_perkID] <- ::new("scripts/dpf/specialperk").init(_chance, _tier, _perkID, _flavorText, _chanceFunction);

		return this.LookupMap[_perkID];
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


::Const.Perks.TalentMultipliers <- {
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
	if (attribute != ::Const.Attributes.COUNT) ::Const.Perks.TalentMultipliers.Multipliers[attribute] <- {};
}

::Const.Perks.DefaultPerkTreeTemplate <- array(::Const.Perks.Perks.len());

foreach (i, row in ::Const.Perks.Perks)
{
	::Const.Perks.DefaultPerkTreeTemplate[i] = array(row.len());
	foreach (j, perk in row)
	{
		::Const.Perks.DefaultPerkTreeTemplate[i][j] = perk.ID;
	}
}

::Const.Perks.DefaultPerkTree <- ::new("scripts/dpf/perk_tree").init(::Const.Perks.DefaultPerkTreeTemplate);
::Const.Perks.DefaultPerkTree.build();

::Const.Perks.PerkGroups.add("DPF_RandomPerkGroup", "Random", ["Random perk group"], []);
::Const.Perks.PerkGroups.add("DPF_NoPerkGroup", "NoPerkGroup", ["No perk group"], []);

::Const.Perks.addPerkGroupToTooltips <- function( _perkID = null, _groups = null )
{
	local map = {};

	foreach (group in ::Const.Perks.PerkGroups.getAll())
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
