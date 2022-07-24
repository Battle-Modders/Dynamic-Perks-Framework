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
});
