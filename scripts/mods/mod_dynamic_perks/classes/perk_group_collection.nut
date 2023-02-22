::DynamicPerks.Class.PerkGroupCollection <- class
{
	ID = null;
	Name = null;
	OrderOfAssignment = null;
	Min = null;
	TooltipPrefix = null
	Groups = null;

	DefaultOptions = null;

	constructor( _options )
	{
		::MSU.requireTable(_options);
		this.__initDefaultOptions();

		foreach (key, value in _options)
		{
			if (!(key in this.DefaultOptions)) throw format("invalid parameter \'%s\'", key);
			this.DefaultOptions[key] = value;
		}

		foreach (key, value in this.DefaultOptions)
		{
			this[key] = value;
		}

		this.DefaultOptions = null;
	}

	function __initDefaultOptions()
	{
		this.DefaultOptions = {
			ID = "",
			Name = "",
			OrderOfAssignment = 10,
			Min = 1,
			TooltipPrefix = "Has perk groups:"
			Groups = []
		};
	}

	function getName()
	{
		return this.Name;
	}

	function setName( _name )
	{
		::MSU.requireString(_name);
		this.Name = _name;
	}

	function getID()
	{
		return this.ID;
	}

	function setID( _id )
	{
		::MSU.requireString(_id);
		this.ID = _id;
	}

	function getGroups()
	{
		return this.Groups;
	}

	function setGroups( _groups )
	{
	::MSU.requireArray(_groups);
		foreach (groupID in _groups)
		{
			if (::DynamicPerks.PerkGroups.findById(groupID) == null)
			{
				::logError(groupID + " is not a valid perk_group ID");
				throw ::MSU.Exception.InvalidType(groupID);
			}
		}
		this.Groups = _groups;
	}

	function getMin()
	{
		return this.Min;
	}

	function setMin( _min )
	{
		::MSU.requireInt(_min);
		this.Min = _min;
	}

	function getTooltipPrefix()
	{
		return this.TooltipPrefix;
	}

	function setTooltipPrefix( _text )
	{
		::MSU.requireString(_text);
		this.TooltipPrefix = _text;
	}

	function getOrderOfAssignment()
	{
		return this.OrderOfAssignment;
	}

	function setOrderOfAssignment( _order )
	{
		::MSU.requireOneFromTypes(["integer", "float"], _order);
		this.OrderOfAssignment = _order;
	}

	function addPerkGroup( _group )
	{
		if (this.Groups.find(_group) != null) this.Groups.push(_group);
	}

	function removePerkGroup( _group )
	{
		local idx = this.Groups.find(_group);
		if (idx != null) return this.Groups.remove(idx);
	}

	function getRandomGroup( _exclude = null )
	{
		if (_exclude != null)
		{
			::MSU.requireArray(_exclude);
			return ::MSU.Array.rand(this.Groups.filter(@(idx, groupID) _exclude.find(groupID) == null));
		}

		return ::MSU.Array.rand(this.Groups);
	}

	function getRandomPerk( _exclude = null )
	{
		return ::DynamicPerks.PerkGroups.findById(this.getRandomGroup()).getRandomPerk(null, _exclude);
	}
};
