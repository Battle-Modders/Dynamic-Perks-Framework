::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function (o) {
	local general_queryUIPerkTooltipData = o.general_queryUIPerkTooltipData;
	o.general_queryUIPerkTooltipData = function( _entityId, _perkId )
	{
		::DPF.PerkTooltipEntityID = _entityId;
		local ret = general_queryUIPerkTooltipData(_entityId, _perkId);
		::DPF.PerkTooltipEntityID = null;
		return ret;
	}
});
