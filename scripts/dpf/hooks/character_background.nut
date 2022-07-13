::mods_hookExactClass("scripts/skills/backgrounds/character_background", function (o) {
	local onSerialize = o.onSerialize;
	o.onSerialize = function( _out )
	{
		onSerialize(_out);
		this.m.PerkTree.onSerialize(_out);
	}

	local onDeserialize = o.onDeserialize;
	o.onDeserialize = function( _in )
	{
		onDeserialize(_in);
		this.m.PerkTree = ::new("scripts/dpf/perk_tree").onDeserialize(_in);
		this.m.PerkTree.build();
	}
});
