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

::Const.Perks.Categories <- {
	LookupMap = ::MSU.Class.OrderedMap(),

	function getAll() {
		return this.LookupMap;
	}

	function findById( _id )
	{
		if (this.LookupMap.contains(_id)) return this.LookupMap[_id];
	}

	function sort()
	{
		this.LookupMap.sort(@( key1, value1, key2, value2 ) value1.m.OrderOfAssignment <=> value2.m.OrderOfAssignment);
	}

	function add( _id, _name, _tooltipPrefix, _min = 1, _groups = null )
	{
		if (this.findById(_id) != null) throw ::MSU.Exception.DuplicateKey(_id);

		local category = ::new("scripts/dpf/perk_group_category").init(_id, _name, _groups);
		category.setTooltipPrefix(_tooltipPrefix);
		category.setMin(_min);
		category.setOrderOfAssignment(this.getAll().len() * 10);

		this.LookupMap[_id] <- category;
	}
};

::Const.Perks.PerkGroups <- {
	LookupMap = {},

	function getAll() {
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
	}
};

::Const.Perks.SpecialPerks <- {
	LookupMap = {},

	function getAll() {
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
	}
};

::Const.Perks.TalentMultipliers <- {};
foreach (attribute in ::Const.Attributes)
{
	::Const.Perks.TalentMultipliers[attribute] <- {};
}
delete ::Const.Perks.TalentMultipliers[::Const.Attributes.COUNT];

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
