this.perk_tree <- {
	m = {
		Tree = [],
		Template = null,
		DynamicMap = null,
		Background = null,
		Exclude = []
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

		if (_dynamicMap != null) this.m.DynamicMap = _dynamicMap;
		else _dynamicMap = {};

		return this;		
	}

	function getTooltip( _flavored = true )
	{
		local ret = this.getPerkGroupsTooltip(_flavored);
		if (ret != "") ret += "\n";
		ret += this.getSpecialPerksTooltip(_flavored);
		return ret;
	}

	function getPerkGroupsTooltip( _flavored = true )
	{
		local ret = "";
		foreach (collection in ::DPF.Perks.PerkGroupCategories.getOrdered())
		{
			local text = "";
			foreach (groupID in collection.getGroups())
			{
				if (this.hasPerkGroup(groupID))
				{
					if (_flavored) text += ::MSU.Array.rand(::DPF.Perks.PerkGroups.findById(groupID).getFlavorText()) + ", ";
					else text += ::DPF.Perks.PerkGroups.findById(groupID).getName() + ", ";
				}
			}

			if (text != "")
			{
				ret += format("%s%s.\n", _flavored ? collection.getTooltipPrefix() + " " : "", text.slice(0, -2));
			}
		}

		return ret == "" ? ret : ret.slice(0, -2);
	}

	function getSpecialPerksTooltip( _flavored = true )
	{
		local ret = "";
		foreach (perk in ::DPF.Perks.SpecialPerks.getAll())
		{
			if (this.hasPerk(perk.getPerkID()))
			{
				if (_flavored) ret += "[color=" + this.Const.UI.Color.NegativeValue + "]" + perk.getFlavorText() + ".[/color]\n";
				else ret += ::Const.Perks.findById(perk.getPerkID()).Name + "\n";
			}
		}

		return ret == "" ? ret : ret.slice(0, -2);
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

		return ret == "" ? ret : ret.slice(0, -2);
	}

	function getPerkGroups()
	{
		local ret = [];
		foreach (collection in ::DPF.Perks.PerkGroupCategories.getOrdered())
		{
			ret.extend(collection.getGroups().filter(@(idx, groupID) this.hasPerkGroup(groupID)));
		}
		return ret;
	}

	function getPerks()
	{
		local ret = [];
		foreach (row in this.getTree())
		{
			foreach (perk in row)
			{
				ret.push(perk.ID);
			}
		}
		return ret;
	}

	function addFromDynamicMap()
	{
		foreach (collection in ::DPF.Perks.PerkGroupCategories.getOrdered())
		{
			if (collection.getID() in this.m.DynamicMap)
			{
				foreach (perkGroupContainer in this.m.DynamicMap[collection.getID()])
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

					local perkGroup = ::DPF.Perks.PerkGroups.findById(id);
					if (perkGroup == null)
					{
						::logError("No perk group with id \'" + id + "\'");
						continue;
					}

					if (perkGroup.getID() == "DPF_RandomPerkGroup") perkGroup = this.__getWeightedRandomGroupFromCollection(categoryName, this.m.Exclude);
					if (perkGroup.getID() != "DPF_NoPerkGroup")
					{
						this.m.Exclude.push(perkGroup.getID());
						this.addPerkGroup(perkGroup.getID());
					}
				}
			}
		}
	}

	function addMins()
	{
		foreach (collection in ::DPF.Perks.PerkGroupCategories.getOrdered())
		{
			local min = this.m.Background.getCollectionMin(collection.getID());
			if (min == null) min = collection.getMin();

			for (local i = (collection.getID() in this.m.DynamicMap) ? this.m.DynamicMap[collection.getID()].len() : 0; i < min; i++)
			{
				local perkGroup = this.__getWeightedRandomGroupFromCollection(collection.getID(), this.m.Exclude);
				if (perkGroup.getID() != "DPF_NoPerkGroup")
				{
					this.m.Exclude.push(perkGroup.getID());
					this.addPerkGroup(perkGroup.getID());
				}
			}
		}
	}

	function addSpecialPerks()
	{
		foreach (specialPerk in ::DPF.Perks.SpecialPerks.getAll())
		{
			local object = specialPerk.roll(this);
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

			this.addPerk(object.PerkID, row + 1);
		}
	}

	function build()
	{
		this.clear();

		if (this.m.Template != null)
		{
			this.buildFromTemplate(this.m.Template);
		}
		else
		{
			this.buildFromDynamicMap();
		}

		if (!::MSU.isNull(this.m.Background)) this.m.Background.onBuildPerkTree();
	}

	function buildFromDynamicMap()
	{
		this.m.Exclude = [];

		foreach (func in ::DPF.Const.PerkTree.PrepareBuildFunctions)
		{
			this[func]();
		}

		this.m.Exclude = null;
		this.m.DynamicMap = null;
	}

	function buildFromTemplate( _template )
	{
		::MSU.requireArray(_template);

		foreach (i, row in _template)
		{
			::MSU.requireArray(row);
			foreach (perkID in row)
			{
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

	function getBackground()
	{
		return this.m.Background;
	}

	function getActor()
	{
		return this.m.Background.getContainer().getActor();
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
		if (_template != null)
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

	function getPerkTier( _perkID )
	{
		foreach (i, row in this.m.Tree)
		{
			foreach (perk in row)
			{
				if (perk.ID == _perkID) return i + 1;
			}
		}
	}

	function addPerk( _perkID, _tier = 1 )
	{
		if (this.hasPerk(_perkID)) return;

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
		foreach (row in ::DPF.Perks.PerkGroups.findById(_perkGroupID).getTree())
		{
			foreach (perk in row)
			{
				if (!this.hasPerk(perk)) return false;
			}
		}

		return true;
	}

	function numPerkGroupsFromCollection( _perkGroupCollection, _exclude = null )
	{
		local count = 0;
		foreach (perkGroupID in _perkGroupCollection.getGroups())
		{
			if (_exclude != null && _exclude.find(perkGroupID) != null) continue;
			if (this.hasPerkGroup(perkGroupID)) count++;
		}

		return count;
	}

	function numPerksFromCollection( _perkGroupCollection, _exclude = null )
	{
		local count = 0;
		foreach (perkGroupID in _perkGroupCollection.getGroups())
		{
			foreach (row in ::DPF.Perks.PerkGroups.findById(perkGroupID).getTree())
			{
				foreach (perkID in row)
				{
					if (_exclude != null && _exclude.find(perkID) != null) continue;
					if (this.hasPerk(perkID)) count++;
				}
			}
		}

		return count;
	}

	function addPerkGroup( _perkGroupID )
	{
		foreach (i, row in ::DPF.Perks.PerkGroups.findById(_perkGroupID).getTree())
		{
			foreach (perk in row)
			{
				this.addPerk(perk, i + 1);
			}
		}
	}

	function removePerkGroup( _perkGroupID )
	{
		foreach (row in ::DPF.Perks.PerkGroups.findById(_perkGroupID).getTree())
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
		foreach (id, mult in this.m.Background.getPerkTreeMultipliers())
		{
			if (!(id in _multipliers)) _multipliers[id] <- mult;
			else
			{
				if (mult < 0 || _multipliers[id] < 0) _multipliers[id] = -1;
				else _multipliers[id] *= mult;
			}
		}
	}

	function addPerkGroupMultipliers( _multipliers )
	{
		foreach (perkGroupID in this.m.Exclude)
		{
			foreach (id, mult in ::DPF.Perks.PerkGroups.findById(perkGroupID).getPerkTreeMultipliers())
			{
				if (!(id in _multipliers)) _multipliers[id] <- mult;
				else
				{
					if (mult < 0 || _multipliers[id] < 0) _multipliers[id] = -1;
					else _multipliers[id] *= mult;
				}
			}
		}
	}

	function addItemMultipliers( _multipliers )
	{
		local items = this.m.Background.getContainer().getActor().getItems().getAllItems();
		foreach (item in items)
		{
			foreach (id, mult in item.getPerkTreeMultipliers())
			{
				if (!(id in _multipliers)) _multipliers[id] <- mult;
				else
				{
					if (mult < 0 || _multipliers[id] < 0) _multipliers[id] = -1;
					else _multipliers[id] *= mult;
				}
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

				foreach (id, mult in ::DPF.Perks.TalentMultipliers.findByAttribute(attribute))
				{
					mult = mult < 1 ? mult / talents[attribute] : mult;
					if (!(id in _multipliers)) _multipliers[id] <- mult;
					else
					{
						if (mult < 0 || _multipliers[id] < 0) _multipliers[id] = -1;
						else _multipliers[id] *= mult;
					}
				}
			}
		}
	}

	function addTraitMultipliers( _multipliers )
	{
		foreach (trait in this.m.Background.getContainer().getSkillsByFunction(@(skill) skill.m.Type == ::Const.SkillType.Trait))
		{
			foreach (id, mult in trait.getPerkTreeMultipliers())
			{
				if (!(id in _multipliers)) _multipliers[id] <- mult;
				else
				{
					if (mult < 0 || _multipliers[id] < 0) _multipliers[id] = -1;
					else _multipliers[id] *= mult;
				}
			}
		}
	}

	function __applyMultipliers( _perkGroupContainer )
	{
		local multipliers = {};

		foreach (func in ::DPF.Const.PerkTree.MultiplierFunctions)
		{
			this[func](multipliers);
		}

		foreach (id, mult in multipliers)
		{
			if (_perkGroupContainer.contains(id))
			{
				if (mult == 0) _perkGroupContainer.setWeight(id, 0);
				else
				{
					if (_perkGroupContainer.getWeight(id) > 0) _perkGroupContainer.setWeight(id, _perkGroupContainer.getWeight(id) * mult);
				}
			}
		}
	}

	function __getWeightedRandomGroupFromCollection( _collectionID, _exclude = null )
	{
		local potentialGroups = ::MSU.Class.WeightedContainer();
		local collection = ::DPF.Perks.PerkGroupCategories.findById(_collectionID)

		foreach (groupID in collection.getGroups())
		{
			if (_exclude != null && _exclude.find(groupID) != null) continue;
			local group = ::DPF.Perks.PerkGroups.findById(groupID);
			potentialGroups.add(group, group.getSelfMultiplier());
		}

		if (potentialGroups.len() != 0)
		{
			foreach (id, mult in collection.getSpecialMultipliers(this))
			{
				if (potentialGroups.contains(id)) potentialGroups.setWeight(id, potentialGroups.getWeight(id) * mult);
			}
			this.__applyMultipliers(potentialGroups);
		}

		local group = potentialGroups.roll();
		return group != null ? group : ::DPF.Perks.PerkGroups.findById("DPF_NoPerkGroup");
	}
}
