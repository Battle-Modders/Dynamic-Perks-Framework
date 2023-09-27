::DynamicPerks.HooksMod.hook("scripts/ui/global/data_helper", function(q) {
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
		}
		return result;
	}
});
