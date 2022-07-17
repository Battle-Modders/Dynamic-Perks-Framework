::mods_hookNewObject("ui/global/data_helper", function (o) {
	local convertEntityToUIData = o.convertEntityToUIData;
	o.convertEntityToUIData = function( _entity, _activeEntity )
	{
		local result = convertEntityToUIData(_entity, _activeEntity);
		if (_entity.getBackground() != null)
		{
			result.perkTree <- _entity.getBackground().getPerkTree().getTree();
		}
		return result;
	}

	o.convertPerksToUIData = function()
	{
		return ::Const.Perks.DefaultPerkTree.getTree();
	}

	o.convertPerkToUIData = function( _perkID, _background )
	{
		local perk = _background.getPerkTree().getPerk(_perkID);

		if (perk != null)
		{
			return {
				id = perk.ID,
				name = perk.Name,
				description = perk.Tooltip,
				imagePath = perk.Icon
			};
		}

		return null;
	}
});
