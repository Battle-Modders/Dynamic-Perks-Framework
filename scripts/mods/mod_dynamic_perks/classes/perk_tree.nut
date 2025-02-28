this.perk_tree <- {
	m = {
		Tree = [],
		Template = null,
		DynamicMap = null,
		Actor = null,
		PerkGroupIDs = [],
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
			local forcedGroups = [];

			if (collection.getID() in this.m.DynamicMap)
			{
				forcedGroups = this.m.DynamicMap[collection.getID()];
				// forcedGroups must be an array or a function that returns an array
				if (typeof forcedGroups == "function")
				{
					forcedGroups = forcedGroups(this);
				}

				foreach (id in forcedGroups)
				{
					if (id == "DynamicPerks_RandomPerkGroup")
						id = collection.getWeightedRandomPerkGroup(this, this.m.PerkGroupIDs);

					if (id == "DynamicPerks_NoPerkGroup")
						continue;

					local perkGroup = ::DynamicPerks.PerkGroups.findById(id);
					if (perkGroup == null)
					{
						::DynamicPerks.Mod.Debug.printError("No perk group with id \'" + id + "\'");
						continue;
					}

					this.addPerkGroup(id);
				}
			}

			local min = this.getActor().getBackground().getPerkGroupCollectionMin(collection);
			if (min == null) min = collection.getMin();

			for (local i = forcedGroups.len(); i < min; i++)
			{
				local perkGroupID = collection.getWeightedRandomPerkGroup(this, this.m.PerkGroupIDs);
				if (perkGroupID != "DynamicPerks_NoPerkGroup")
				{
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

		this.m.PerkGroupIDs = [];

		if (this.m.Template != null)
		{
			this.buildFromTemplate(this.m.Template);
		}
		else
		{
			this.buildFromDynamicMap();
		}

		if (!::MSU.isNull(this.getActor()))
		{
			this.getActor().getBackground().onBuildPerkTree();
		}

		if ("Assets" in ::World && !::MSU.isNull(::World.Assets) && !::MSU.isNull(::World.Assets.getOrigin()))
		{
			::World.Assets.getOrigin().onBuildPerkTree(this);
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
		this.m.PerkGroupIDs.clear();
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

		foreach (pgID in perk.PerkGroupIDs)
		{
			if (!this.hasPerkGroup(pgID))
			{
				foreach (row in ::DynamicPerks.PerkGroups.findById(pgID).getTree())
				{
					foreach (perkID in row)
					{
						if (!this.hasPerk(perkID))
						{
							return;
						}
					}
				}
				this.m.PerkGroupIDs.push(pgID);
			}
		}
	}

	function removePerk( _perkID )
	{
		delete this.m.PerkLookupMap[_perkID];

		foreach (row in this.m.Tree)
		{
			foreach (i, perk in row)
			{
				if (perk.ID == _perkID)
				{
					foreach (pgID in perk.PerkGroupIDs)
					{
						::MSU.Array.removeByValue(this.m.PerkGroupIDs, pgID);
					}
					row.remove(i);
					return;
				}
			}
		}
	}

	function hasPerkGroup( _perkGroupID )
	{
		return this.m.PerkGroupIDs.find(_perkGroupID) != null;
	}

	function addPerkGroup( _perkGroupID )
	{
		if (this.m.PerkGroupIDs.find(_perkGroupID) == null)
			this.m.PerkGroupIDs.push(_perkGroupID);

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
		::MSU.Array.removeByValue(this.m.PerkGroupIDs, _perkGroupID);

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

	function getPerkGroupMultiplierSources_All()
	{
		local ret = [];
		ret.extend(this.getPerkGroupMultiplierSources_Skills());
		ret.extend(this.getPerkGroupMultiplierSources_PerkGroups());
		ret.extend(this.getPerkGroupMultiplierSources_Items());
		return ret;
	}

	function getPerkGroupMultiplierSources_Skills()
	{
		return this.getActor().getSkills().m.Skills;
	}

	function getPerkGroupMultiplierSources_PerkGroups()
	{
		return this.m.PerkGroupIDs.map(@(_pgID) ::DynamicPerks.PerkGroups.findById(_pgID));
	}

	function getPerkGroupMultiplierSources_Items()
	{
		return this.getActor().getItems().getAllItems();
	}

	function applyMultipliers( _perkGroupContainer )
	{
		local perkTree = this;

		_perkGroupContainer.apply(function( _perkGroupID, _weight )
		{
			if (_weight == 0 || _weight == -1)
				return _weight;

			local mult;
			foreach (source in perkTree.getPerkGroupMultiplierSources_All())
			{
				mult = source.getPerkGroupMultiplier(_perkGroupID, perkTree);
				if (mult == null)
					continue;
				if (mult == 0 || mult == -1)
					return mult;
				_weight *= mult;
			}

			return _weight;
		});
	}
};
