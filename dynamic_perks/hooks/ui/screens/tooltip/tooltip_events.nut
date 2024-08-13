::DynamicPerks.HooksMod.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.general_queryUIPerkTooltipData = @() function( _entityId, _perkId )
	{
		local perk = ::Const.Perks.findById(_perkId);
		if (perk == null)
			return null;

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

		if (::MSU.isIn("PerkGroupIDs", perk, true))
		{
			foreach (perkGroupID in perk.PerkGroupIDs)
			{
				local pg = ::DynamicPerks.PerkGroups.findById(perkGroupID);
				ret.push({
					id = 3,
					type = "hint",
					icon = pg.getIcon(),
					text = ::DynamicPerks.Mod.Tooltips.parseString(format("[%s|PerkGroup+%s] perk group", pg.getName(), perkGroupID))
				});
			}
		}

		local player = ::Tactical.getEntityByID(_entityId);
		if (player == null)
			return ret;

		if (!player.hasPerk(_perkId))
		{
			local reqTier = player.getPerkTree().getPerkTier(_perkId);

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

			if (::MSU.isIn("verifyPrerequisites", perk, true)) perk.verifyPrerequisites(player, ret);
		}

		return ret;
	}
});
