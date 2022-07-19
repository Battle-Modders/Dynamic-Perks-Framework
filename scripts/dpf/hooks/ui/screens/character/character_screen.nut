::mods_hookNewObject("ui/screens/character/character_screen", function (o) {
	::logInfo("hooked");
	o.general_onQueryPerkInformation = function( _data )
	{
		return this.UIDataHelper.convertPerkToUIData(_data[0], _data[1]);
	}
});
