this.perk_group_collection <- {
	m = {
		ID = "perk_group_collection.uninitiatlized",
		Name = "Uninitialized perk group collection",
		OrderOfAssignment = 10,
		Min = 1,
		Groups = []
	},
	function create()
	{
	}

	function init( _id, _name = null, _min = null, _groups = null )
	{
		this.setID(_id);
		this.setName(_name != null ? _name : _id);
		if (_min != null) this.setMin(_min);
		if (_groups != null) this.setGroups(_groups);

		return this;
	}

	function getName()
	{
		return this.m.Name;
	}

	function setName( _name )
	{
		::MSU.requireString(_name);
		this.m.Name = _name;
	}

	function getID()
	{
		return this.m.ID;
	}

	function setID( _id )
	{
		::MSU.requireString(_id);
		this.m.ID = _id;
	}

	function getGroups()
	{
		return this.m.Groups;
	}

	function setGroups( _groups )
	{
	::MSU.requireArray(_groups);
		foreach (groupID in _groups)
		{
			if (::DynamicPerks.PerkGroups.findById(groupID) == null)
			{
				::DynamicPerks.Mod.Debug.printError(groupID + " is not a valid perk_group ID");
				throw ::MSU.Exception.InvalidType(groupID);
			}
		}
		this.m.Groups = _groups;
	}

	function getMin()
	{
		return this.m.Min;
	}

	function setMin( _min )
	{
		::MSU.requireInt(_min);
		this.m.Min = _min;
	}

	function getOrderOfAssignment()
	{
		return this.m.OrderOfAssignment;
	}

	function setOrderOfAssignment( _order )
	{
		::MSU.requireOneFromTypes(["integer", "float"], _order);
		this.m.OrderOfAssignment = _order;
	}

	function addPerkGroup( _group )
	{
		if (this.m.Groups.find(_group) == null) this.m.Groups.push(_group);
	}

	function removePerkGroup( _group )
	{
		local idx = this.m.Groups.find(_group);
		if (idx != null) return this.m.Groups.remove(idx);
	}

	function getRandomGroup( _exclude = null )
	{
		if (_exclude != null)
		{
			::MSU.requireArray(_exclude);
			return ::MSU.Array.rand(this.m.Groups.filter(@(idx, groupID) _exclude.find(groupID) == null));
		}

		return ::MSU.Array.rand(this.m.Groups);
	}

	function getRandomPerk( _exclude = null )
	{
		return ::DynamicPerks.PerkGroups.findById(this.getRandomGroup()).getRandomPerk(null, _exclude);
	}

	function getWeightedRandomPerkGroup( _perkTree, _filterFunc = null )
	{
		local potentialGroups = ::MSU.Class.WeightedContainer();

		foreach (groupID in this.getGroups())
		{
			if (_perkTree.hasPerkGroup(groupID))
				continue;

			if (_filterFunc == null || _filterFunc(groupID))
			{
				local group = ::DynamicPerks.PerkGroups.findById(groupID);
				potentialGroups.add(group.getID(), group.getSelfMultiplier(_perkTree));
			}
		}

		if (potentialGroups.len() != 0)
		{
			_perkTree.applyMultipliers(potentialGroups);
		}

		local groupID = potentialGroups.roll();

		return groupID != null ? groupID : "DynamicPerks_NoPerkGroup";
	}
};
