::DynamicPerks.Mod.Tooltips.setTooltips({
	PerkGroup = ::MSU.Class.CustomTooltip(function(_data){
		local perkGroup = ::DynamicPerks.PerkGroups.findById(_data.ExtraData);
		return perkGroup.getTooltip();
	})
});
