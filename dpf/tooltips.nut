local tooltips = {
	Perks = {
		GenericTooltip = ::MSU.Class.CustomTooltip(function(_data){
			local id = _data.perkID
        	if (!(id in ::Const.Perks.LookupMap))
        		return null;
        	local perk = ::Const.Perks.LookupMap[id];
        	return [
        		{
        			id = 1,
        			type = "title",
        			text = perk.Name
        		},
        		{
        			id = 2,
        			type = "description",
        			text = perk.Tooltip
        		}
        	];
    	}),
	}
}

::DPF.Mod.Tooltips.setTooltips(tooltips);
