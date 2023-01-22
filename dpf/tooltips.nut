local tooltips = {
	Perks = {
		GenericTooltip = ::MSU.Class.CustomTooltip(function(_data){
        	local perk = ::Const.Perks.findById(_data.perkID);
        	if (perk == null)
        		return null;
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
