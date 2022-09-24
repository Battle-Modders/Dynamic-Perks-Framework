::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function (o) {
	local general_queryUIPerkTooltipData = o.general_queryUIPerkTooltipData;
	o.general_queryUIPerkTooltipData = function( _entityId, _perkId )
	{
		::DPF.PerkTooltipEntityID = _entityId;

		local player = ::Tactical.getEntityByID(_entityId);
		// Temporary Switcheroo so that the vanilla function does its warnings according to our newly defined 'getPerkTier' function
		local getPerkPointsSpent = player.getPerkPointsSpent;
		player.getPerkPointsSpent = player.getPerkTier;

		local ret = general_queryUIPerkTooltipData(_entityId, _perkId);

		player.getPerkPointsSpent = getPerkPointsSpent;
		::DPF.PerkTooltipEntityID = null;

		return ret;
	}
});
