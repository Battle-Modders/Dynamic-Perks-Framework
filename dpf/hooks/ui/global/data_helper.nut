::mods_hookNewObject("ui/global/data_helper", function (o) {
	local convertEntityToUIData = o.convertEntityToUIData;
	o.convertEntityToUIData = function( _entity, _activeEntity )
	{
		local result = convertEntityToUIData(_entity, _activeEntity);
		if (_entity.getBackground() != null)
		{
			local perkTree = _entity.getBackground().getPerkTree().getTree();
			foreach (i, row in perkTree)
			{
				foreach (perk in row)
				{
					perk.Unlocks = i + 1;
					perk.Tier <- i + 1;
				}
			}

			result.perkTree <- _entity.getBackground().getPerkTree().getTree();
			result.perkTier <- _entity.getPerkTier();
		}
		return result;
	}

	o.convertPerkToUIData = function( _perkId )
	{
		::logInfo("convertPerkToUIData");
		::MSU.Log.printStackTrace();
		local perk = this.Const.Perks.findById(_perkId);

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

	o.convertPerksToUIData = function()
	{
		::logInfo("convertPerksssssssssssssToUIData");
		::MSU.Log.printStackTrace();
		return this.Const.Perks.Perks;
	}
});
