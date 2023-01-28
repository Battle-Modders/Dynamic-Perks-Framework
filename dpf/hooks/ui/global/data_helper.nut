::mods_hookNewObject("ui/global/data_helper", function (o) {
	local convertEntityToUIData = o.convertEntityToUIData;
	o.convertEntityToUIData = function( _entity, _activeEntity )
	{
		local result = convertEntityToUIData(_entity, _activeEntity);
		if (_entity.getBackground() != null)
		{
			local perkTree = _entity.getBackground().getPerkTree();
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
