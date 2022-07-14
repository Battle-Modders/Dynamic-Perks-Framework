::mods_hookExactClass("scripts/entity/tactical/player", function (o) {
	local setStartValuesEx = o.setStartValuesEx;
	o.setStartValuesEx = function( _backgrounds, _addTraits = true );
	{
		setStartValuesEx(_backgrounds, _addTraits);
		this.getBackground().buildPerkTree();
	}
});
