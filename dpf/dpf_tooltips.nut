::DPF.Mod.Tooltips.setTooltips({
	PerkGroup = ::MSU.Class.CustomTooltip(function(_data){
		local perkGroup = ::DPF.Perks.PerkGroups.findById(_data.ExtraData);
		return perkGroup.getTooltip();
	})
});
