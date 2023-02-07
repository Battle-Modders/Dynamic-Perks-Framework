::DynamicPerks.Mod.Tooltips.setTooltips({
	PerkGroup = ::MSU.Class.CustomTooltip(function(_data){
		local perkGroup = ::DynamicPerks.Perks.PerkGroups.findById(_data.ExtraData);
		return perkGroup.getTooltip();
	})
});
