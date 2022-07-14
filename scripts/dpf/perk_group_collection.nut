this.perk_group_collection <- ::inherit("scripts/config/legend_dummy_bb_class", {
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
			foreach (group in _groups)
			{
				if (!::MSU.isKindOf("perk_group", group))
				{
					::logError("Each element in _groups must be a perk_group object.");
					throw ::MSU.Exception.InvalidType(group);
				}
			}
			this.m.Groups = _groups;
		}
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
			return ::MSU.Groups.rand(this.Groups.filter(@(idx, group) _exclude.find(group.getID()) == null));
		}

		return ::MSU.Groups.rand(this.Groups);
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
		if (this.m.PlayerSpecificFunction == null) return;
		this.m.PlayerSpecificFunction(_player);
	}
});
