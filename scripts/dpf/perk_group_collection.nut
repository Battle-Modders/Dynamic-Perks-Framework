this.perk_group_collection <- ::inherit("scripts/config/legend_dummy_bb_class", {
	m = {
		Groups = [],
		PlayerSpecificFunction = null, // TODO: Need better name for the variable and associated functions
	},
	function create()
	{
	}

	function init( _groups = null )
	{
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

	function getList()
	{
		return this.m.Groups;
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
