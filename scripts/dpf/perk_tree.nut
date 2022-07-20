this.perk_tree <- {
	m = {
		Tree = [],
		Template = null,
		DynamicMap = null,
		Background = null,
		LocalMap = null,
		Traits = null,
		PrepareBuildFunctions = [
			"setupLocalMap",
			"addFromDynamicMap",
			"addMins",
			"setupTemplate",
			"addSpecialPerksToTemplate"
		],
		MultiplierFunctions = [
			"addBackgroundMultipliers",
			"addLocalMapMultipliers",
			"addWeaponMultipliers",
			"addTalentMultipliers",
			"addTraitMultipliers"
		]
	},
	function create()
	{
	}

	function init( _template = null, _dynamicMap = null )
	{
		if (_template != null)
		{
			this.setTemplate(_template);
			return this;
		}

		if (_dynamicMap == null)
		{
			::logError("A \'_dynamicMap\' must be provided if \'_template\' is null.");
			throw ::MSU.Exception.InvalidValue(_dynamicMap);
		}

		this.m.DynamicMap = _dynamicMap;

		return this;		
	}

	function getTooltip()
	{
		local ret = "";
		foreach (category in ::Const.Perks.Categories.getAll())
		{
			local text = category.getTooltipPrefix() + " ";
			local has = false;
			foreach (groupID in category.getList())
			{
				if (this.hasPerkGroup(groupID))
				{
					has = true;
					text += ::MSU.Array.rand(::Const.Perks.PerkGroups.findById(groupID).getFlavorText()) + ", ";
				}
			}

			if (has) ret += text.slice(0, -2) + ".\n";
		}

		foreach (perk in ::Const.Perks.SpecialPerks.getAll())
		{
			if (this.hasPerk(perk.getPerkID()))
			{
				ret += "[color=" + this.Const.UI.Color.NegativeValue + "]" + perk.getFlavorText() + ".[/color]\n";
			}
		}

		return ret;
	}

	function getPerksTooltip()
	{
		local ret = "";
		foreach (row in this.m.Tree)
		{
			foreach (perk in row)
			{
				ret += perk.Name + ", ";
			}
			ret = ret.slice(0, -2) + "\n";
		}
		return ret;
	}

	function setupLocalMap()
	{
		this.m.LocalMap = {};
		foreach (category in ::Const.Perks.Categories.getAll())
		{
			this.m.LocalMap[category.getID()] <- [];
		}
	}

	function addFromDynamicMap()
	{
		foreach (category in ::Const.Perks.Categories.getAll())
		{
			if (category.getID() in this.m.DynamicMap)
			{
				local exclude = array(this.m.LocalMap[category.getID()].len());
				foreach (i, perkGroup in this.m.LocalMap[category.getID()])
				{
					exclude[i] = perkGroup.getID();
				}

				foreach (perkGroupContainer in this.m.DynamicMap[category.getID()])
				{
					local id;

					switch (typeof perkGroupContainer)
					{
						case "string":
							id = perkGroupContainer;
							break;

						case "instance":
							this.__applyMultipliers(perkGroupContainer);
							id = perkGroupContainer.roll();
							break;

						default:
							::logError("perkGroupContainer must either be a valid perk group id or an instance of the MSU WeightedContainer class");
							throw ::MSU.Exception.InvalidType("perkGroupContainer");
					}

					local perkGroup = ::Const.Perks.PerkGroups.findById(id);
					if (perkGroup == null)
					{
						::logError("No perk group with id \'" + id + "\'");
						continue;
					}

					if (perkGroup.getID() == "DPF_RandomPerkGroup") perkGroup = this.__getWeightedRandomGroupFromCategory(categoryName, exclude);

					this.m.LocalMap[category.getID()].push(perkGroup);
					if (perkGroup.getID() != "DPF_NoPerkGroup") exclude.push(perkGroup.getID());
				}
			}
		}
	}

	function addMins()
	{
		foreach (category in ::Const.Perks.Categories.getAll())
		{
			local min = this.m.Background.getCategoryMin(category.getID());
			if (min == null) min = category.getMin();

			if (min > 0)
			{
				local exclude = array(this.m.LocalMap[category.getID()].len());
				foreach (i, perkGroup in this.m.LocalMap[category.getID()])
				{
					exclude[i] = perkGroup.getID();
				}

				local r = ::Math.rand(0, 100);
				for (local i = this.m.LocalMap[category.getID()].len(); i < min; i++)
				{
					local perkGroup = this.__getWeightedRandomGroupFromCategory(category.getID(), exclude);
					this.m.LocalMap[category.getID()].push(perkGroup);
					exclude.push(perkGroup.getID());
				}
			}
		}
	}

	function setupTemplate()
	{
		this.m.Template = [ [], [], [], [], [], [], [] ]; // Length 7

		foreach (category in this.m.LocalMap)
		{
			foreach (perkGroup in category)
			{
				foreach (rowNumber, perkIDs in perkGroup.getTree())
				{
					while (this.m.Template.len() < rowNumber + 1)
					{
						this.m.Template.push([]);
					}

					foreach (perkID in perkIDs)
					{
						this.m.Template[rowNumber].push(perkID);
					}
				}
			}
		}
	}

	function addSpecialPerksToTemplate()
	{
		foreach (specialPerk in ::Const.Perks.SpecialPerks.getAll())
		{
			local object = specialPerk.roll(this.m.Background.getContainer().getActor());
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
	}

	function build()
	{
		if (this.m.Template != null)
		{
			this.buildFromTemplate(this.m.Template);
			return;
		}

		this.m.Traits = this.m.Background.getContainer().getSkillsByFunction(@(skill) skill.m.Type == ::Const.SkillType.Trait);

		foreach (func in this.m.PrepareBuildFunctions)
		{
			this[func]();
		}

		this.buildFromTemplate(this.m.Template);

		this.m.LocalMap = null;
		this.m.DynamicMap = null;
		this.m.Template = null;
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
				this.addPerk(perkID, i + 1);
			}
		}

		if (!::MSU.isNull(this.m.Background)) this.m.Background.onBuildPerkTree();
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

	function getBackground()
	{
		return this.m.Background;
	}

	function setBackground( _background )
	{
		if (!::MSU.isKindOf(_background, "character_background")) throw ::MSU.Exception.InvalidType(_background);
		this.m.Background = ::MSU.asWeakTableRef(_background);
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

		this.m.Template = _template;
	}

	function merge( _other, _rebuild = true )
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

		if (_rebuild) this.buildFromTemplate(template);
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

	function addPerk( _perkID, _tier = 1 )
	{
		// Don't use hasPerk because that also considers perks in the LocalMap
		// which causes the perks to never be added during dynamic build
		// as it thinks that it already has the perk.
		if (this.getPerk(_perkID) != null) return;

		local perk = clone ::Const.Perks.findById(_perkID);
		perk.Row <- _tier - 1;
		perk.Unlocks <- _tier - 1;
		while (this.m.Tree.len() < _tier)
		{
			this.m.Tree.push([]);
		}
		this.m.Tree[_tier - 1].push(perk);
	}

	function removePerk( _perkID )
	{
		foreach (row in this.m.Tree)
		{
			foreach (i, perk in row)
			{
				if (perk.ID == _perkID) row.remove(i);
			}
		}
	}

	function hasPerkGroup( _perkGroupID )
	{
		foreach (row in ::Const.Perks.PerkGroups.findById(_perkGroupID).getTree())
		{
			foreach (perk in row)
			{
				if (!this.hasPerk(perk)) return false;
			}
		}

		return true;
	}

	function hasPerkGroupsFromCollection( _perkGroupCollectionID, _minCount = 1, _exclude = null )
	{
		local collection = ::Const.Perks.PerkGroupCollections.findById(_perkGroupCollectionID);
		if (collection == null) collection = ::Const.Perks.PerkGroupCategories.findById(_perkGroupCollectionID);

		if (collection == null)
		{
			::logError(_perkGroupCollectionID + " must be a valid perk_group_collection or perk_group_category ID");
			throw :MSU.Exception.InvalidValue(_perkGroupCollectionID);
		}

		local count = 0;

		foreach (perkGroupID in collection.getList())
		{
			if (_exclude != null && _exclude.find(perkGroupID)) continue;

			if (this.hasPerkGroup(perkGroupID))
			{
				count++;
				if (count >= _minCount) return true;
			}
		}

		return false;
	}

	function hasPerksFromCollection( _perkGroupCollectionID, _minCount = 1, _exclude = null )
	{
		local collection = ::Const.Perks.PerkGroupCollections.findById(_perkGroupCollectionID);
		if (collection == null) collection = ::Const.Perks.PerkGroupCategories.findById(_perkGroupCollectionID);

		if (collection == null)
		{
			::logError(_perkGroupCollectionID + " must be a valid perk_group_collection or perk_group_category ID");
			throw :MSU.Exception.InvalidValue(_perkGroupCollectionID);
		}

		local count = 0;

		foreach (perkGroupID in collection.getList())
		{
			foreach (row in ::Const.Perks.PerkGroups.findById(perkGroupID))
			{
				foreach (perkID in row)
				{
					if (_exclude != null && _exclude.find(perkID)) continue;

					if (this.hasPerkGroup(perkGroupID))
					{
						count++;
						if (count >= _minCount) return true;
					}
				}
			}
		}

		return false;
	}

	function addPerkGroup( _perkGroupID )
	{
		foreach (i, row in ::Const.Perks.PerkGroups.findById(_perkGroupID).getTree())
		{
			foreach (perk in row)
			{
				this.addPerk(perk, i + 1);
			}
		}
	}

	function removePerkGroup( _perkGroupID )
	{
		foreach (row in ::Const.Perks.PerkGroups.findById(_perkGroupID).getTree())
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
			}
		}
	}

	function onDeserialize( _in )
	{
		this.m.Tree = array(_in.readU8());
		for (local i = 0; i < this.m.Tree.len(); i++)
		{
			this.m.Tree[i] = [];
		}
		for (local i = 0; i < this.m.Tree.len(); i++)
		{
			local len = _in.readU8();
			for (local j = 0; j < len; j++)
			{
				this.addPerk(_in.readString(), i+1);
			}
		}
	}

	function addBackgroundMultipliers( _multipliers )
	{
		foreach (id, mult in this.m.Background.m.Multipliers)
		{
			if (id in _multipliers) _multipliers[id] = _multipliers[id] * mult;
			else _multipliers[id] <- mult;
		}
	}

	function addLocalMapMultipliers( _multipliers )
	{
		foreach (category in this.m.LocalMap)
		{
			foreach (perkGroup in category)
			{
				foreach (id, mult in perkGroup.getMultipliers())
				{
					if (id in _multipliers) _multipliers[id] = _multipliers[id] * mult;
					else _multipliers[id] <- mult;
				}
			}
		}
	}

	function addWeaponMultipliers( _multipliers )
	{
		local weapon = this.m.Background.getContainer().getActor().getMainhandItem();
		if (weapon != null)
		{
			local perkGroups = [];

			foreach (weaponTypeName, weaponType in ::Const.Items.WeaponType)
			{
				if (weapon.isWeaponType(weaponType) && (weaponTypeName in ::Const.Perks.PerkGroups.getAll()))
				{
					perkGroups.push(::Const.Perks.PerkGroups[weaponTypeName]);
				}
			}

			if (perkGroups.len() > 0)
			{
				_multipliers[::MSU.Array.rand(perkGroups)] <- -1;
			}
		}
	}

	function addTalentMultipliers( _multipliers )
	{
		if (this.m.Background.getContainer().getActor().getTalents().len() > 0)
		{
			local talents = this.m.Background.getContainer().getActor().getTalents();

			for (local attribute = 0; attribute < this.Const.Attributes.COUNT; attribute++)
			{
				if (talents[attribute] == 0) continue;

				foreach (id, mult in ::Const.Perks.TalentMultipliers[attribute])
				{
					mult = mult < 1 ? mult / talents[attribute] : mult;
					if (id in _multipliers) _multipliers[id] = _multipliers[id] * mult;
					else _multipliers[id] <- mult;
				}
			}
		}
	}

	function addTraitMultipliers( _multipliers )
	{
		if (this.m.Traits != null)
		{
			foreach (trait in this.m.Traits)
			{
				foreach (id, mult in trait.m.Multipliers)
				{
					if (id in _multipliers) _multipliers[id] = _multipliers[id] * mult;
					else _multipliers[id] <- mult;
				}
			}
		}
	}

	function __applyMultipliers( _perkGroupContainer )
	{
		local multipliers = {};

		foreach (func in this.m.MultiplierFunctions)
		{
			this[func](multipliers);
		}

		foreach (id, mult in multipliers)
		{
			if (_perkGroupContainer.contains(id)) _perkGroupContainer.setWeight(id, _perkGroupContainer.getWeight(id) * mult);
		}
	}

	function __getWeightedRandomGroupFromCategory( _categoryID, _exclude = null )
	{
		local potentialGroups = ::MSU.Class.WeightedContainer();
		local category = ::Const.Perks.Categories.findById(_categoryID)

		foreach (groupID in category.getList())
		{
			if (_exclude != null && _exclude.find(groupID) != null) continue;
			local group = ::Const.Perks.PerkGroups.findById(groupID);
			potentialGroups.add(group, group.getSelfMultiplier());
		}

		if (potentialGroups.len() != 0)
		{
			foreach (id, mult in category.getSpecialMultipliers(this))
			{
				if (potentialGroups.contains(id)) potentialGroups.setWeight(id, potentialGroups.getWeight(id) * mult);
			}
			this.__applyMultipliers(potentialGroups);
		}

		local group = potentialGroups.roll();
		return group != null ? group : ::Const.Perks.PerkGroups.findById("DPF_NoPerkGroup");
	}
}
