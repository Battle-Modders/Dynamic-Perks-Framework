::DynamicPerks.HooksMod.hook("scripts/ui/global/data_helper", function(q) {
	// this might need to get to get refactored at some point to be more performant
	q.dpf_convertEntityPerkGroupsToUIData <- function(_entity)
	{
		local ret = {
			perkGroups = [],
			perkGroupsOrdered = [],
		};
		local perkTree = _entity.getPerkTree();
		local perkGroupIDs = perkTree.getPerkGroups();
		foreach (idx, category in ::DynamicPerks.PerkGroupCategories.getOrdered())
		{
			local row = [];
			foreach (perkGroupID in category.getGroups())
			{
				if (perkGroupIDs.find(perkGroupID) == null)
					continue;
				local perkGroup = ::DynamicPerks.PerkGroups.findById(perkGroupID);
				local uiData = perkGroup.toUIData();
				ret.perkGroups.push(uiData);
				row.push(uiData);
			}
			if (row.len() > 0)
				ret.perkGroupsOrdered.push(row);
		}

		local specialRow = [];
		foreach (perkGroup in ::DynamicPerks.PerkGroups.getByType(::DynamicPerks.Class.SpecialPerkGroup))
		{
			if (perkTree.hasPerkGroup(perkGroup.getID()))
			{
				local uiData = perkGroup.toUIData();
				ret.perkGroups.push(uiData);
				specialRow.push(uiData);
			}
		}
		if (specialRow.len() > 0)
			ret.perkGroupsOrdered.push(specialRow);
		return ret;
	}

	q.convertEntityToUIData = @(__original) function( _entity, _activeEntity )
	{
		local result = __original(_entity, _activeEntity);
		if (_entity != null)
		{
			local perkTree = _entity.getPerkTree();
			result.perkTree <- perkTree.toUIData();
			result.perkTier <- _entity.getPerkTier();
			result.lockedPerks <- [];
			foreach (id, perk in perkTree.getPerks())
			{
				if (!_entity.isPerkUnlockable(id)) result.lockedPerks.push(id);
			}
			local perkGroups = this.dpf_convertEntityPerkGroupsToUIData(_entity);
			result.perkGroups <- perkGroups.perkGroups;
			result.perkGroupsOrdered <- perkGroups.perkGroupsOrdered;
		}
		return result;
	}
});
