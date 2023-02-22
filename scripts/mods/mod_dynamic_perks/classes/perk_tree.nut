::DynamicPerks.Class.PerkTree <- class
{
	Tree = null;
	Template = null;
	DynamicMap = null;
	Actor = null;
	Exclude = null;
	PerkLookupMap = null;

	DefaultOptions = null;

	constructor( _options = null )
	{
		if (_options != null) ::MSU.requireTable(_options);
		else _options = {};
		this.__initDefaultOptions();

		foreach (key, value in _options)
		{
			if (!(key in this.DefaultOptions)) throw format("invalid parameter \'%s\'", key);
			this.DefaultOptions[key] = value;
		}

		this.Tree = [];
		this.Exclude = [];
		this.PerkLookupMap = {};

		if (this.DefaultOptions.Template != null)
		{
			this.setTemplate(this.DefaultOptions.Template);
		}

		this.DynamicMap = this.DefaultOptions.DynamicMap != null ? this.DefaultOptions.DynamicMap : {};

		this.DefaultOptions = null;
	}

	function __initDefaultOptions()
	{
		this.DefaultOptions = {
			Template = null,
			DynamicMap = null
		};
	}

	function getTooltip( _flavored = true )
	{
		local ret = this.getPerkGroupsTooltip(_flavored);
		if (ret != "") ret += "\n";
		ret += this.getSpecialPerkGroupsTooltip(_flavored);
		return ret;
	}

	function getSpecialPerkGroupsTooltip( _flavored = true )
	{
		local ret = "";
		foreach (group in ::DynamicPerks.PerkGroups.getByType(::DynamicPerks.Class.SpecialPerkGroup))
		{
			if (this.hasPerkGroup(group.getID()))
			{
				local str = _flavored ? ::MSU.Array.rand(group.getFlavorText()) : group.getName();
				if (str != "") ret += ::MSU.Text.color("#000ec1", str) + "\n";
			}
		}
		return ret == "" ? ret : ret.slice(0, -1); // remove \n
	}

	function getPerkGroupsTooltip( _flavored = true )
	{
		local ret = "";
		foreach (collection in ::DynamicPerks.PerkGroupCategories.getOrdered())
		{
			local text = "";
			foreach (groupID in collection.getGroups())
			{
				if (this.hasPerkGroup(groupID))
				{
					local str = _flavored ? ::MSU.Array.rand(::DynamicPerks.PerkGroups.findById(groupID).getFlavorText()) : ::DynamicPerks.PerkGroups.findById(groupID).getName();
					if (str != "") text += str + ", ";
				}
			}

			if (text != "")
			{
				ret += format("%s%s.\n", _flavored ? collection.getTooltipPrefix() + " " : "", text.slice(0, -2)); // remove ", "
			}
		}

		return ret == "" ? ret : ret.slice(0, -1); // remove \n
	}

	function getPerksTooltip()
	{
		local ret = "";
		foreach (row in this.Tree)
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
			if (collection.getID() in this.DynamicMap)
			{
				foreach (perkGroupContainer in this.DynamicMap[collection.getID()])
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

					if (id == "DynamicPerks_RandomPerkGroup")
						id = this.__getWeightedRandomGroupFromCollection(collection.getID(), this.Exclude);

					if (id == "DynamicPerks_NoPerkGroup")
						continue;

					local perkGroup = ::DynamicPerks.PerkGroups.findById(id);
					if (perkGroup == null)
					{
						::logError("No perk group with id \'" + id + "\'");
						continue;
					}

					this.Exclude.push(id);
					this.addPerkGroup(id);
				}
			}

			local min = this.getActor().getBackground().getCollectionMin(collection.getID());
			if (min == null) min = collection.getMin();

			for (local i = (collection.getID() in this.DynamicMap) ? this.DynamicMap[collection.getID()].len() : 0; i < min; i++)
			{
				local perkGroupID = this.__getWeightedRandomGroupFromCollection(collection.getID(), this.Exclude);
				if (perkGroupID != "DynamicPerks_NoPerkGroup")
				{
					this.Exclude.push(perkGroupID);
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

		this.Exclude = [];

		if (this.Template != null)
		{
			this.buildFromTemplate(this.Template);
		}
		else
		{
			this.buildFromDynamicMap();
		}

		this.Exclude = null;

		if (!::MSU.isNull(this.getActor())) this.getActor().getBackground().onBuildPerkTree();
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
		local ret = array(this.Tree.len());
		foreach (i, row in this.Tree)
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
		local ret = array(this.Tree.len());
		foreach (i, row in this.Tree)
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
					Name = perk.Name
				}
			}
		}
		return ret;
	}

	function hasPerk( _id )
	{
		return _id in this.PerkLookupMap;
	}

	function getPerk( _id )
	{
		return this.PerkLookupMap[_id];
	}

	function getPerks()
	{
		return this.PerkLookupMap;
	}

	function getPerkTier( _id )
	{
		return this.PerkLookupMap[_id].Row + 1;
	}

	function getTree()
	{
		return this.Tree;
	}

	function getActor()
	{
		return this.Actor;
	}

	function setActor( _actor )
	{
		if (!::MSU.isKindOf(_actor, "player")) throw ::MSU.Exception.InvalidType(_actor);
		this.Actor = ::MSU.asWeakTableRef(_actor);
	}

	function getTemplate()
	{
		return this.Template;
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

		this.Template = _template;
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
		this.Tree.clear();
		this.PerkLookupMap.clear();
	}

	function addPerk( _perkID, _tier = 1 )
	{
		if (this.hasPerk(_perkID)) return;

		local perk = {
			Row = _tier - 1,
			Unlocks = _tier - 1,
		}.setdelegate(::Const.Perks.findById(_perkID));

		this.PerkLookupMap[_perkID] <- perk;

		while (this.Tree.len() < _tier)
		{
			this.Tree.push([]);
		}
		this.Tree[_tier - 1].push(perk);
	}

	function removePerk( _perkID )
	{
		foreach (row in this.Tree)
		{
			foreach (i, perk in row)
			{
				if (perk.ID == _perkID) row.remove(i);
			}
		}
		delete this.PerkLookupMap[_perkID];
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
		_out.writeU8(this.Tree.len());
		foreach (row in this.Tree)
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
		this.Tree = array(_in.readU8());
		for (local i = 0; i < this.Tree.len(); i++)
		{
			this.Tree[i] = [];
		}
		for (local i = 0; i < this.Tree.len(); i++)
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
		foreach (perkGroupID in this.Exclude)
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

	function __getWeightedRandomGroupFromCollection( _collectionID, _exclude = null )
	{
		local potentialGroups = ::MSU.Class.WeightedContainer();
		local collection = ::DynamicPerks.PerkGroupCategories.findById(_collectionID)

		foreach (groupID in collection.getGroups())
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
};
