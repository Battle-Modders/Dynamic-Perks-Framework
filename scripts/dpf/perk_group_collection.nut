this.perk_group_collection <- {
	m = {
		ID = "perk_group_collection.uninitiatlized",
		Name = "Uninitialized perk group collection"
		Groups = [],
		PlayerSpecificFunction = null, // TODO: Need better name for the variable and associated functions
	},
	function create()
	{
	}

	function init( _id, _name, _groups = null )
	{
		this.setID(_id);
		this.setName(_name);
		if (_groups != null)
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

	function getList()
	{
		return this.m.Groups;
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

	function setPlayerSpecificFunction( _function )
	{
		::MSU.requireFunction(_function);
		this.m.PlayerSpecificFunction = _function;
	}

	function playerSpecificFunction( _player )
	{
		if (this.m.PlayerSpecificFunction != null) return this.m.PlayerSpecificFunction(_player);
	}
};
