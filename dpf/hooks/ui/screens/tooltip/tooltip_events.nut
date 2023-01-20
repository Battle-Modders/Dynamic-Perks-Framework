::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function (o) {
	local general_queryUIPerkTooltipData = o.general_queryUIPerkTooltipData;
	o.general_queryUIPerkTooltipData = function( _entityId, _perkId )
	{
		local player = ::Tactical.getEntityByID(_entityId);
		if (player == null) return null;

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
				local reqTier = player.getBackground().getPerkTree().getPerkTier(_perkId);

				if (player.getPerkTier() >= reqTier)
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
				else if (reqTier - player.getPerkTier() > 1)
				{
					ret.push({
						id = 3,
						type = "hint",
						icon = "ui/icons/icon_locked.png",
						text = "Locked until " + (reqTier - player.getPerkTier()) + " more perk points are spent"
					});
				}
				else
				{
					ret.push({
						id = 3,
						type = "hint",
						icon = "ui/icons/icon_locked.png",
						text = "Locked until " + (reqTier - player.getPerkTier()) + " more perk point is spent"
					});
				}

				if ("verifyPrerequisites" in perk) perk.verifyPrerequisites(player, ret);
			}

			return ret;
		}

		return null;
	}
});
