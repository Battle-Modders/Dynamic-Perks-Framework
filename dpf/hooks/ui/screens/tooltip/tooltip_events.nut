::mods_hookNewObject("ui/screens/tooltip/tooltip_events", function (o) {
	// local general_queryUIPerkTooltipData = o.general_queryUIPerkTooltipData;
	// o.general_queryUIPerkTooltipData = function( _entityId, _perkId )
	// {
	// 	::DPF.PerkTooltipEntityID = _entityId;
	// 	local ret = general_queryUIPerkTooltipData(_entityId, _perkId);
	// 	::DPF.PerkTooltipEntityID = null;
	// 	return ret;
	// }

	o.general_queryUIPerkTooltipData = function( _entityId, _perkId )
	{
		local player = ::Tactical.getEntityByID(_entityId);
		local perk = player.getBackground().getPerkTree().getPerk(_perkId);

		if (perk != null)
		{
			local ret = [
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

			if (!player.hasPerk(_perkId))
			{
				if (player.getBackground().getPerkTree().isPerkUnlockable(_perkId))
				{
					if (player.getPerkPoints() == 0)
					{
						ret.push({
							id = 3,
							type = "hint",
							icon = "ui/icons/icon_locked.png",
							text = "Available, but this character has no perk point to spend"
						});
					}
				}

				ret.extend(player.getBackground().getPerkTree().getPerkRequirementsTooltip(_perkId));
			}

			return ret;
		}

		return null;
	}
});
