this.dynamic_perks_js_connection <- ::inherit("scripts/mods/msu/js_connection", {
	m = {},
	function create()
	{
		this.m.ID = "DynamicPerksJSConnection";
	}

	function connect()
	{
		::logInfo("Connect");
		this.m.JSHandle = ::UI.connect("DynamicPerksJSConnection", this);
		::DynamicPerks.addPerkGroupToTooltips();
	}

	function updatePerkToGroupPerksMap( _perkID, _groups )
	{
		local perkIDs = [_perkID];
		foreach (group in _groups)
		{
			foreach (row in group.getTree())
			{
				foreach (perkID in row)
				{
					if (perkID != _perkID) perkIDs.push(perkID);
				}
			}
		}
		this.m.JSHandle.asyncCall("updatePerkToGroupPerksMap", perkIDs);
	}
})
