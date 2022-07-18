this.perk_tree <- {
	m = {
		Tree = [],
		Template = null,
		DynamicMap = null,
		Player = null,
		LocalMap = null,
		Traits = null
	}

	function create()
	{
	}

	function init( _template = null, _background = null, _map = null )
	{
		if (_template != null)
		{
			this.m.Template = _template;
			return this;
		}

		if (!::MSU.isKindOf(_background, "character_background")) throw ::MSU.Exception.InvalidType(_background);
		if (_background == null || _map == null)
		{
			::logError("Both \'_background\' and \'_map\' must be provided if \'_template\' is null.");
			throw ::MSU.Exception.InvalidValue(_background);
		}

		this.m.Player = ::MSU.asWeakTableRef(_background.getContainer().getActor());
		this.m.DynamicMap = _map;

		return this;		
	}

	function getTooltip()
	{
		local ret = "";
		foreach (category in ::Const.Perks.Category)
		{
			local text = category.getTooltipPrefix();
			local has = false;
			foreach (group in category.getList())
			{
				if (this.hasPerkGroup(group))
				{
					has = true;
					text += ::MSU.Array.rand(group.getFlavorText()) + ", ";
				}
			}

			if (has) ret += text.slice(0, -2) + ".\n";
		}
		return ret;
	}

	function build()
	{
		if (this.m.Template != null)
		{
			this.buildFromTemplate(this.m.Template);
			return;
		}

		this.m.LocalMap = {};
		this.m.Traits = ::MSU.isNull(this.m.Player) ? null : this.m.Player.getSkills().getSkillsByFunction(@(skill) skill.m.Type == ::Const.SkillType.Trait);

		foreach (categoryName, category in ::Const.Perks.Category)
		{
			this.m.LocalMap[categoryName] <- [];

			if (categoryName in this.m.DynamicMap)
			{
				local exclude = array(this.m.LocalMap[categoryName].len());
				foreach (i, perkGroup in this.m.LocalMap[categoryName])
				{
					exclude[i] = perkGroup.getID();
				}

				foreach (perkGroupContainer in this.m.DynamicMap[categoryName])
				{
					local perkGroup;

					if (typeof perkGroupContainer == "string")
					{
						perkGroup = ::Const.Perks.PerkGroup.findById(perkGroupContainer);
						if (perkGroup == null) ::logError(format("No perk group with id \'%s\'", perkGroupContainer));
					}
					else
					{
						this.__applyMultipliers(perkGroupContainer);
						perkGroup = ::Const.Perks.PerkGroup.findById(perkGroupContainer.roll());
					}

					if (perkGroup == null) perkGroup = ::Const.Perks.PerkGroup.findById("DPF_NonePerkGroup");
					else if (perkGroup.getID() == "DPF_RandomPerkGroup") perkGroup = this.__getWeightedRandomGroupFromCategory(categoryName, exclude);

					this.m.LocalMap[categoryName].push(perkGroup);
					if (perkGroup.getID() != "DPF_NonePerkGroup") exclude.push(perkGroup.getID());
				}
			}

			if (category.getMin() > 0)
			{
				::Const.Perks.Category[categoryName].playerSpecificFunction(this.m.Player);

				local exclude = array(this.m.LocalMap[categoryName].len());
				foreach (i, perkGroup in this.m.LocalMap[categoryName])
				{
					exclude[i] = perkGroup.getID();
				}

				local r = ::Math.rand(0, 100);
				for (local i = this.m.LocalMap[categoryName].len(); i < category.getMin(); i++)
				{
					local perkGroup = this.__getWeightedRandomGroupFromCategory(categoryName, exclude);
					this.m.LocalMap[categoryName].push(perkGroup);
					exclude.push(perkGroup.getID());
				}
			}
		}

		this.m.Template = array(11);

		foreach (category in this.m.LocalMap)
		{
			foreach (perkGroup in category)
			{
				foreach (rowNumber, perkIDs in perkGroup.getTree())
				{
					this.m.Template[rowNumber] = array(perkIDs.len());
					foreach (i, perkID in perkIDs)
					{
						this.m.Template[rowNumber][i] = perkID;
					}
				}
			}
		}

		foreach (specialPerk in ::Const.Perks.SpecialPerks)
		{
			local object = specialPerk.roll(this.m.Player);
			if (object == null) continue;

			local hasRow = false;
			local direction = -1;
			local row = object.Tier - 1;

			while (row >= 0 && row <= 6)
			{
				if (this.m.Template[row].len() < 13)
				{
					hasRow = true;
					break;
				}

				row += direction;

				if (row == -1)
				{
					row = object.Tier - 1;
					direction = 1;
				}
			}

			row = hasRow ? this.Math.max(0, this.Math.min(row, 6)) : object.Tier - 1;

			this.m.Template[row].push(object.PerkID);
		}

		this.m.LocalMap = null;
		this.m.Traits = null;
		this.m.DynamicMap = null;
		this.m.Player = null;

		this.buildFromTemplate(this.m.Template);
	}

	function buildFromTemplate( _template )
	{
		::MSU.requireArray(_template);

		this.clear();

		foreach (i, row in _template)
		{
			::MSU.requireArray(row);
			foreach (perkID in row)
			{
				//::lOginfo("Going to add perk " + perkID + " in row " + i + " which means tier " + (i+1));
				this.addPerk(perkID, i + 1);
			}
		}
	}

	function toTemplate()
	{
		local ret = array(this.m.Tree.len());
		foreach (i, row in this.m.Tree)
		{
			ret[i] = array(row.len());
			foreach (i, perk in row)
			{
				ret[i][j] = perk.ID;
			}
		}
		return ret;
	}

	function getTree()
	{
		return this.m.Tree;
	}

	function getTemplate()
	{
		return this.m.Template;
	}

	function setTemplate( _template )
	{
		::MSU.requireArray(_template);
		foreach (row in _template)
		{
			foreach (perkID in row)
			{
				if (::Const.Perks.findById(perkID) == null)
				{
					::logError(perkID + " is not a valid perk ID.");
					throw ::MSU.Exception.InvalidValue(perkID);
				}
			}
		}
	}

	function merge( _other )
	{
		_other = _other.toTemplate();
		local template = this.toTemplate();
		foreach (i, row in _other)
		{
			if (template.len() < i + 1) template[i] = [];

			foreach (perk in row)
			{
				if (template[i].find(perk) == null) template[i].push(perk);
			}
		}
		this.buildFromTemplate(template);
	}

	function clear()
	{
		this.m.Tree.clear();
	}

	function hasPerk( _id )
	{
		foreach (row in this.m.Tree)
		{
			foreach (perk in row)
			{
				if (perk.ID == _id) return true;
			}
		}

		if (this.m.LocalMap != null)
		{
			foreach (category in this.m.LocalMap)
			{
				foreach (perkGroup in category)
				{
					if (perkGroup.hasPerk(_id)) return true;
				}
			}
		}

		return false;
	}

	function getPerk( _id )
	{
		foreach (row in this.m.Tree)
		{
			foreach (perk in row)
			{
				if (perk.ID == _id) return perk;
			}
		}
	}

	function addPerk( _perkID, _tier = 1, _isRefundable = true )
	{
		//::lOginfo("== addPerk ==");
		if (this.hasPerk(_perkID)) return;

		local perk = clone ::Const.Perks.findById(_perkID);
		perk.Row <- _tier - 1;
		perk.Unlocks <- _tier - 1;
		perk.IsRefundable <- _isRefundable;
		//::lOginfo("Tree len is " + this.m.Tree.len() + " and _tier is " + _tier);
		while (this.m.Tree.len() < _tier)
		{
			//::lOginfo("Tree is smaller than _tier so adding a row to tree");
			this.m.Tree.push([]);
		}
		//::lOginfo("pushing the perk to index " + (_tier - 1));
		this.m.Tree[_tier - 1].push(perk);
		foreach (row in this.m.Tree)
		{
			foreach (perk in row)
			{
				//::lOginfo(perk.ID);
			}
		}
	}

	function removePerk( _perkID )
	{
		foreach (row in this.m.Tree)
		{
			foreach (i, perk in row)
			{
				if (perk.ID == _perk) return row.remove(i);
			}
		}
	}

	function hasPerkGroup( _perkGroup )
	{
		foreach (row in _perkGroup.getTree())
		{
			foreach (perk in row)
			{
				if (!this.hasPerk(perk)) return false;
			}
		}

		return true;
	}

	function addPerkGroup( _perkGroup, _isRefundable = true )
	{
		foreach (i, row in _perkGroup.getTree())
		{
			foreach (perk in row)
			{
				this.addPerk(perk, i + 1, _isRefundable);
			}
		}
	}

	function removePerkGroup( _perkGroup )
	{
		foreach (row in _perkGroup.getTree())
		{
			foreach (perk in row)
			{
				this.removePerk(perk);
			}
		}
	}

	function onSerialize( _out )
	{
		_out.writeU8(this.m.Tree.len());
		foreach (row in this.m.Tree)
		{
			_out.writeU8(row.len());
			foreach (perk in row)
			{
				_out.writeString(perk.ID);
				_out.writeBool(perk.IsRefundable);
			}
		}
	}

	function onDeserialize( _in )
	{
		this.m.Tree = array(_in.readU8());
		for (local i = 0; i < this.m.Tree.len(); i++)
		{
			this.m.Tree[i] = [];
			local len = _in.readU8();
			for (local j = 0; j < len; j++)
			{
				this.addPerk(_in.readString(), i+1, _in.readBool());
			}
		}
	}

	function __applyMultipliers( _perkGroupContainer )
	{
		local multipliers = clone this.m.Player.getBackground().m.PerkGroupMultipliers;

		foreach (category in this.m.LocalMap)
		{
			foreach (perkGroup in category)
			{
				multipliers.extend(perkGroup.getPerkGroupMultipliers());
			}
		}

		local weapon = this.m.Player.getMainhandItem();
		if (weapon != null)
		{
			local perkGroups = [];

			foreach (weaponTypeName, weaponType in ::Const.Items.WeaponType)
			{
				if (weapon.isWeaponType(weaponType) && (weaponTypeName in ::Const.Perks.PerkGroup))
				{
					perkGroups.push(::Const.Perks.PerkGroup[weaponTypeName]);
				}
			}

			if (perkGroups.len() > 0)
			{
				multipliers.push([[-1, ::MSU.Array.rand(perkGroups)]]);
			}
		}

		if (this.m.Player.getTalents().len() > 0)
		{
			local talents = this.m.Player.getTalents();

			for (local attribute = 0; attribute < this.Const.Attributes.COUNT; attribute++)
			{
				if (talents[attribute] == 0) continue;

				foreach (mult in ::Const.Perks.TalentMultipliers[attribute])
				{
					multipliers.push(
						[mult[0] < 1 ? mult[0] / talents[attribute] : mult[0] * talents[attribute], mult[1]]
					);
				}
			}
		}

		if (this.m.Traits != null)
		{
			foreach (trait in this.m.Traits)
			{
				multipliers.extend(trait.m.PerkGroupMultipliers);
			}
		}

		foreach (multiplier in multipliers)
		{
			local perkGroup = multiplier[1];
			if (_perkGroupContainer.contains(perkGroup)) _perkGroupContainer.setWeight(perkGroup, _perkGroupContainer.getWeight(perkGroup) * multiplier[0]);
		}
	}

	function __getWeightedRandomGroupFromCategory ( _categoryName, _exclude = null )
	{
		local potentialGroups = ::MSU.Class.WeightedContainer();

		foreach (group in ::Const.Perks.Category[_categoryName].getList())
		{
			if (_exclude != null && _exclude.find(group.getID()) != null) continue;
			potentialGroups.add(group, group.getSelfMultiplier());
		}

		if (potentialGroups.len() != 0)
		{
			this.__applyMultipliers(potentialGroups);
		}

		local group = potentialGroups.roll();
		return group != null ? group : ::Const.Perks.PerkGroup.findById("DPF_NonePerkGroup");
	}
}
