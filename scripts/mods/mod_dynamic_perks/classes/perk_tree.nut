this.perk_tree <- ::inherit(::MSU.BBClass.Empty, {
	m = {
		Tree = [],
		Template = null,
		DynamicMap = null,
		Actor = null,
		Exclude = [],
		PerkLookupMap = {},
		MaxWidth = 13
	},
	function create()
	{
	}

	function init( _options )
	{
		::MSU.requireTable(_options);

		local options = {
			Template = null,
			DynamicMap = null
		};
		foreach (key, value in _options)
		{
			if (!(key in options)) throw format("invalid parameter \'%s\'", key);
			options[key] = value;
		}

		if (options.Template != null)
		{
			this.setTemplate(options.Template);
			return this;
		}

		this.m.DynamicMap = options.DynamicMap != null ? options.DynamicMap : {};

		return this;		
	}

	function getPerkGroups()
	{
		local ret = [];
		foreach (collection in ::DynamicPerks.PerkGroupCategories.getOrdered())
		{
			ret.extend(collection.getGroups().filter((@(idx, groupID) this.hasPerkGroup(groupID)).bindenv(this)));
		}
		return ret;
	}

	function addFromDynamicMap()
	{
		foreach (collection in ::DynamicPerks.PerkGroupCategories.getOrdered())
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
							::DynamicPerks.Mod.Debug.printError("perkGroupContainer must either be a valid perk group id or an instance of the MSU WeightedContainer class");
							throw ::MSU.Exception.InvalidType("perkGroupContainer");
					}

					if (id == "DynamicPerks_RandomPerkGroup")
						id = this.__getWeightedRandomGroupFromCollection(collection, this.m.Exclude);

					if (id == "DynamicPerks_NoPerkGroup")
						continue;

					local perkGroup = ::DynamicPerks.PerkGroups.findById(id);
					if (perkGroup == null)
					{
						::DynamicPerks.Mod.Debug.printError("No perk group with id \'" + id + "\'");
						continue;
					}

					this.m.Exclude.push(id);
					this.addPerkGroup(id);
				}
			}

			local min = this.getActor().getBackground().getPerkGroupCollectionMin(collection);
			if (min == null) min = collection.getMin();

			for (local i = (collection.getID() in this.m.DynamicMap) ? this.m.DynamicMap[collection.getID()].len() : 0; i < min; i++)
			{
				local perkGroupID = this.__getWeightedRandomGroupFromCollection(collection, this.m.Exclude);
				if (perkGroupID != "DynamicPerks_NoPerkGroup")
				{
					this.m.Exclude.push(perkGroupID);
					this.addPerkGroup(perkGroupID);
				}
			}
		}
	}

	function addSpecialPerkGroups()
	{
		foreach (group in ::DynamicPerks.PerkGroups.getByType(::DynamicPerks.Class.SpecialPerkGroup))
		{
			if (group.roll(this))
			{
				this.addPerkGroup(group.getID());
			}
		}
	}

	function build()
	{
		this.clear();

		this.m.Exclude = [];

		if (this.m.Template != null)
		{
			this.buildFromTemplate(this.m.Template);
		}
		else
		{
			this.buildFromDynamicMap();
		}

		this.m.Exclude = null;

		if (!::MSU.isNull(this.getActor()))
		{
			this.getActor().getBackground().onBuildPerkTree();

			if ("Assets" in ::World && !::MSU.isNull(::World.Assets))
			{
				::World.Assets.getOrigin().onBuildPerkTree(this.getActor());
			}
		}
	}

	function buildFromDynamicMap()
	{
		this.addFromDynamicMap();
		this.addSpecialPerkGroups();
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
			foreach (j, perk in row)
			{
				ret[i][j] = perk.ID;
			}
		}
		return ret;
	}

	function toUIData()
	{
		local self = this;
		local ret = array(this.m.Tree.len());
		foreach (i, row in this.m.Tree)
		{
			ret[i] = array(row.len());
			foreach (j, perk in row)
			{
				ret[i][j] = {
					ID = perk.ID,
					IconDisabled = perk.IconDisabled,
					Icon = perk.Icon,
					Row = perk.Row,
					Tooltip = perk.Tooltip,
					Name = perk.Name,
					PerkGroupIDs = perk.PerkGroupIDs.filter(@(_, _id) self.hasPerkGroup(_id))
				}
			}
		}
		return ret;
	}

	function hasPerk( _id )
	{
		return _id in this.m.PerkLookupMap;
	}

	function getPerk( _id )
	{
		return this.m.PerkLookupMap[_id];
	}

	function getPerks()
	{
		return this.m.PerkLookupMap;
	}

	function getPerkTier( _id )
	{
		return this.m.PerkLookupMap[_id].Row + 1;
	}

	function getTree()
	{
		return this.m.Tree;
	}

	function getActor()
	{
		return this.m.Actor;
	}

	function setActor( _actor )
	{
		if (!::MSU.isKindOf(_actor, "player")) throw ::MSU.Exception.InvalidType(_actor);
		this.m.Actor = ::MSU.asWeakTableRef(_actor);
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
						::DynamicPerks.Mod.Debug.printError(perkID + " is not a valid perk ID.");
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
		this.m.PerkLookupMap.clear();
	}

	function addPerk( _perkID, _tier = 1, _ignoreMaxWidth = false )
	{
		local perkDef = ::Const.Perks.findById(_perkID);
		if (perkDef == null)
		{
			::DynamicPerks.Mod.Debug.printError("No perk with ID: " + _perkID);
			return;
		}

		if (this.hasPerk(_perkID)) return;

		local perk = {
			Row = _tier - 1,
			Unlocks = _tier - 1,
		}.setdelegate(perkDef);

		this.m.PerkLookupMap[_perkID] <- perk;

		while (this.m.Tree.len() < _tier)
		{
			this.m.Tree.push([]);
		}

		local row = _tier - 1;
		if (!_ignoreMaxWidth && this.m.Tree[row].len() >= this.m.MaxWidth)
		{
			local distance = 1;
			while (row + distance < this.m.Tree.len() || row - distance >= 0)
			{
				if (row + distance < this.m.Tree.len() && this.m.Tree[row + distance].len() < this.m.MaxWidth)
				{
					row += distance;
					break;
				}
				if (row - distance >= 0 && this.m.Tree[row - distance].len() < this.m.MaxWidth)
				{
					row -= distance;
					break;
				}
				distance++;
			}
		}

		this.m.Tree[row].push(perk);
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
		delete this.m.PerkLookupMap[_perkID];
	}

	function hasPerkGroup( _perkGroupID )
	{
		foreach (row in ::DynamicPerks.PerkGroups.findById(_perkGroupID).getTree())
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
			foreach (row in ::DynamicPerks.PerkGroups.findById(perkGroupID).getTree())
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
		foreach (i, row in ::DynamicPerks.PerkGroups.findById(_perkGroupID).getTree())
		{
			foreach (perk in row)
			{
				this.addPerk(perk, i + 1);
			}
		}
	}

	function removePerkGroup( _perkGroupID )
	{
		foreach (row in ::DynamicPerks.PerkGroups.findById(_perkGroupID).getTree())
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

	function addSkillMultipliers( _multipliers )
	{
		foreach (skill in this.getActor().getSkills().m.Skills)
		{
			foreach (id, mult in skill.getPerkTreeMultipliers())
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

	function addPerkGroupMultipliers( _multipliers )
	{
		foreach (perkGroupID in this.m.Exclude)
		{
			foreach (id, mult in ::DynamicPerks.PerkGroups.findById(perkGroupID).getPerkTreeMultipliers())
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
		local items = this.getActor().getItems().getAllItems();
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
		if (this.getActor().getTalents().len() > 0)
		{
			local talents = this.getActor().getTalents();

			for (local attribute = 0; attribute < this.Const.Attributes.COUNT; attribute++)
			{
				if (talents[attribute] == 0) continue;

				foreach (id, mult in ::DynamicPerks.TalentMultipliers.findByAttribute(attribute))
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

	function getAllMultipliers()
	{
		local ret = {};
		this.addSkillMultipliers(ret);
		this.addPerkGroupMultipliers(ret);
		this.addItemMultipliers(ret);
		this.addTalentMultipliers(ret);
		return ret;
	}

	function __applyMultipliers( _perkGroupContainer )
	{
		foreach (id, mult in this.getAllMultipliers())
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

	function __getWeightedRandomGroupFromCollection( _collection, _exclude = null )
	{
		local potentialGroups = ::MSU.Class.WeightedContainer();

		foreach (groupID in _collection.getGroups())
		{
			if (_exclude != null && _exclude.find(groupID) != null) continue;
			local group = ::DynamicPerks.PerkGroups.findById(groupID);
			potentialGroups.add(group.getID(), group.getSelfMultiplier(this));
		}

		if (potentialGroups.len() != 0)
		{
			this.__applyMultipliers(potentialGroups);
		}

		local groupID = potentialGroups.roll();

		return groupID != null ? groupID : "DynamicPerks_NoPerkGroup";
	}
});
