::Const.Perks.Category <- ::MSU.Class.OrderedMap();
::Const.Perks.PerkDefs <- [];
::Const.Perks.PerkGroup <- {
	function findById( _id )
	{
		foreach (id, group in this)
		{
			if (id == _id) return group;
		}
	}
};
::Const.Perks.SpecialPerks <- { // TODO: Standardize plural and singular usage in variable names
	function findById( _id )
	{
		foreach (id, group in this)
		{
			if (id == _id) return group;
		}
	}
};

local defaultTemplate = array(::Const.Perks.Perks.len());

foreach (i, row in ::Const.Perks.Perks)
{
	defaultTemplate[i] = array(row.len());
	foreach (j, perkDef in row)
	{
		defaultTemplate[i][j] = perkDef.ID;
		::Const.Perks.PerkDefs.push(perkDef);
	}
}

::Const.Perks.DefaultPerkTree <- ::new("scripts/dpf/perk_tree").init(defaultTemplate);
::Const.Perks.DefaultPerkTree.build();

// local tree = ::Const.Perks.DefaultPerkTree.getTree();
// ::MSU.Log.printData(tree, 99);
// foreach (i, row in tree)
// {
// 	::logInfo("ROW " + i + " type: " + typeof row);
// 	foreach (perkDef in row)
// 	{
// 		::logInfo(typeof perkDef);
// 		::MSU.Log.printData(perkDef);
// 	}
// }

::Const.Perks.addPerkGroup <- function ( _id, _name, _flavorText, _tree, _multipliers = null )
{
	if (_id in ::Const.Perks.PerkGroup) throw ::MSU.Exception.DuplicateKey(_id);
	::Const.Perks.PerkGroup[_id] <- ::new("scripts/dpf/perk_group").init(_id, _name, _flavorText, _tree, _multipliers);
}

::Const.Perks.addPerkGroup("DPF_RandomPerkGroup", "Random", ["Random perk group"], [ [], [], [], [], [], [], [], [], [], [], [] ]);
::Const.Perks.addPerkGroup("DPF_NonePerkGroup", "None", ["None perk group"], [ [], [], [], [], [], [], [], [], [], [], [] ]);

::Const.Perks.addCategory <- function ( _id, _name, _tooltipPrefix, _min = 1, _groups = null )
{
	if (::Const.Perks.Category.contains(_name)) ::logWarning(format("A category with id \'%s\' and name \'%s\' already exists.", _id, _name));

	local category = ::new("scripts/dpf/perk_group_category").init(_id, _name, _groups);
	category.setTooltipPrefix(_tooltipPrefix);
	category.setMin(_min);
	category.setOrderOfAssignment(::Const.Perks.Category.len() * 10);

	::Const.Perks.Category[_name] <- category;
}

::Const.Perks.addSpecialPerk <- function( _chance, _tier, _perkID, _flavorText, _chanceFunction = null )
{
	if (_perkID in ::Const.Perks.SpecialPerks) throw ::MSU.Exception.DuplicateKey(_perkID);
	::Const.Perks.SpecialPerks[_perkID] <- ::new("scripts/dpf/specialperk").init(_chance, _tier, _perkID, _flavorText, _chanceFunction);
}

::Const.Perks.addPerkDefs <- function( _perkDefs )
{
	local i = ::Const.Perks.PerkDefs.len();

	::Const.Perks.PerkDefs.extend(_perkDefs);

	foreach (perkDef in _perkDefs)
	{
		::Const.Perks.LookupMap[perkDef.ID] <- perkDef;
		i++;
	}
}

::Const.Perks.addPerkGroupToTooltips <- function( _perkID = null, _groups = null )
{
	local map = {};

	foreach (group in ::Const.Perks.PerkGroup)
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

		local perkDef = ::Const.Perks.findById(perkID);
		local desc = perkDef.Tooltip;

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
			perkDef.Tooltip += "\n\n" + pre + mid + ap;
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

			perkDef.Tooltip += text;
		}
	}
}
