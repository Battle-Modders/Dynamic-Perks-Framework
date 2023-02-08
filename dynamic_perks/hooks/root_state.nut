::mods_hookExactClass("root_state", function(o){
	local onInit = o.onInit;
	o.onInit = function(){
		onInit();
		local tooltipImageKeywords = {};
		foreach (perkGroup in ::DynamicPerks.PerkGroups.getAll())
		{
			if (perkGroup.getIcon() == "")
				continue;
			tooltipImageKeywords[perkGroup.getIcon()] <- "PerkGroup+" + perkGroup.getID();
		}
		::DynamicPerks.Mod.Tooltips.setTooltipImageKeywords(tooltipImageKeywords);
	}
})
