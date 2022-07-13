::Const.Perks.OrderOfAssignment <- [];
::Const.Perks.Mins <- {};
::Const.Perks.Category <- {};
::Const.Perks.PerkDefs <- [];
::Const.Perks.DynamicPerkTreeMins = {};

foreach (i, row in ::Const.Perks.Perks)
{
	::Const.Perks.DefaultPerkTreeTemplate[i] = array(row.len());
	foreach (j, perkDef in row)
	{
		::Const.Perks.DefaultPerkTreeTemplate[i][j] = perkDef.ID;
		::Const.Perks.PerkDefs.push(perkDef);
	}
}

::Const.Perks.DefaultPerkTree <- ::new("scripts/dpf/perk_tree").init(::Const.Perks.DefaultPerkTreeTemplate);

::Const.Perks.addCategory <- function ( _name, _min = 0, _groups = null )
{
	if (_name in ::Const.Perks.Category) throw ::MSU.Exception.DuplicateKey(_name);

	::Const.Perks.Category[_name] <- ::new("scripts/dpf/perk_group_collection").init(_groups);
	::Const.Perks.DynamicPerkTreeMins[_name] <- _min;
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

::Const.Perks.updatePerkGroupTooltips <- function( _perkID = null, _groups = null )
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
