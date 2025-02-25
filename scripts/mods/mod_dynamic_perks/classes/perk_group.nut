this.perk_group <- {
	m = {
		ID = "not_initialized",
		Name = "Not initialized Perk Group",
		Description = "",
		Icon = "",
		Tree = []
	},
	function create()
	{
	}

	function init( _id, _name, _tree, _multipliers = null )
	{
		::MSU.requireString(_id);

		this.m.ID = _id;
		this.setName(_name);
		this.setTree(_tree);

		if (_multipliers != null) this.setMultipliers(_multipliers);

		return this;
	}

	function getTooltip()
	{
		local ret = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = this.getDescription()
			}
		];

		foreach (i, row in this.getTree())
		{
			local perks = [];
			foreach (j, perkID in row)
			{
				local perkDef = ::Const.Perks.findById(perkID);
				perks.push({
					id = 10,
					type = "text",
					icon = perkDef.Icon,
					text = perkDef.Name
				});
			}

			ret.push({
				id = 3 + i,
				type = "text",
				text = "Tier " + (i + 1) + ":",
				children = perks
			});
		}

		return ret;
	}

	function getID()
	{
		return this.m.ID;
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

	function getDescription()
	{
		return this.m.Description;
	}

	function getIcon()
	{
		return this.m.Icon;
	}

	function getTree()
	{
		return this.m.Tree;
	}

	function setTree( _tree )
	{
		::MSU.requireArray(_tree);
		foreach (row in _tree)
		{
			::MSU.requireArray(row);
			foreach (perk in row)
			{
				if (::Const.Perks.findById(perk) == null) throw ::MSU.Exception.InvalidValue(perk);
			}
		}

		this.m.Tree = _tree;
	}

	function toUIData()
	{
		return {
			ID = this.getID(),
			Name = this.getName(),
			Description = this.getDescription(),
			Icon = this.getIcon()
		}
	}

	function getPerkGroupMultiplier( _groupID, _perkTree )
	{
		return 1.0;
	}

	function getSelfMultiplier( _perkTree )
	{
		return  1.0;
	}

	function hasPerk( _id )
	{
		return this.findPerk(_id) != null;
	}

	function findPerk( _id )
	{
		foreach (row in this.getTree())
		{
			foreach (perk in row)
			{
				if (perk == _id) return row;
			}
		}
	}

	function addPerk( _id, _tier )
	{
		if (::Const.Perks.findById(_id) == null) throw ::MSU.Exception.InvalidValue(_id);

		local row = this.findPerk(_id);
		if (row != null)
		{
			::DynamicPerks.Mod.Debug.printWarning("Perk " + _id + " already exists in perk group " + this.getID() + " at tier " + (row + 1));
			return;
		}

		this.getTree()[_tier-1].push(_id);
	}

	function removePerk( _id )
	{
		foreach (row in this.getTree())
		{
			foreach (i, perk in row)
			{
				if (perk == _id) return row.remove(i);
			}
		}
	}

	function getRandomPerk( _tier = null, _exclude = null )
	{
		local perks = [];
		if (_tier != null)
		{
			foreach (perk in this.getTree()[tier-1])
			{
				if (_exclude == null || _exclude.find(perk) == null) perks.push(perk);
			}
		}
		else
		{
			foreach (row in this.getTree())
			{
				foreach (perk in row)
				{
					if (_exclude == null || _exclude.find(perk) == null) perks.push(perk);
				}
			}
		}

		return ::MSU.Array.rand(perks);
	}
};
