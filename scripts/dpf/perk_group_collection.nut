this.perk_group_collection <- {
	m = {
		ID = "perk_group_collection.uninitiatlized",
		Name = "Uninitialized perk group collection",
		OrderOfAssignment = 10,
		Min = 1,
		TooltipPrefix = "Has perk groups:"
		Groups = []
	},
	function create()
	{
	}

	function init( _id, _name, _tooltipPrefix = null, _min = null, _groups = null )
	{
		this.setID(_id);
		this.setName(_name);
		if (_tooltipPrefix != null) this.setTooltipPrefix(_tooltipPrefix);
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
			if (::Const.Perks.PerkGroups.findById(groupID) == null)
			{
				::logError(groupID + " is not a valid perk_group ID");
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

	function getTooltipPrefix()
	{
		return this.m.TooltipPrefix;
	}

	function setTooltipPrefix( _text )
	{
		::MSU.requireString(_text);
		this.m.TooltipPrefix = _text;
	}

	function getOrderOfAssignment()
	{
		return this.m.OrderOfAssignment;
	}

	function setOrderOfAssignment( _order )
	{
		::MSU.requireInt(_order);
		this.m.OrderOfAssignment = _order;
	}

	function getSpecialMultipliers( _perkTree )
	{
		return {};
	}

	function addPerkGroup( _group )
	{
		if (this.m.Groups.find(_group) != null) this.m.Groups.push(_group);
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
			return ::Const.Perks.PerkGroups.findById(::MSU.Array.rand(this.m.Groups.filter(@(idx, groupID) _exclude.find(groupID) == null)));
		}

		return ::Const.Perks.PerkGroups.findById(::MSU.Array.rand(this.m.Groups));
	}

	function getRandomPerk( _exclude = null )
	{
		return this.getRandomGroup().getRandomPerk(null, _exclude);
	}


};
