::mods_hookExactClass("skills/backgrounds/character_background", function (o) {
	o.m.Multipliers <- {};
	o.m.PerkTree <- ::new("scripts/dpf/perk_tree").init(::Const.Perks.DefaultPerkTreeTemplate);

	o.onBuildPerkTree <- function()
	{
	}

	local onAdded = o.onAdded;
	o.onAdded = function()
	{
		onAdded();
		this.m.PerkTree.setBackground(this);
	}

	o.getPerkTree <- function()
	{
		return this.m.PerkTree;
	}

	o.getCategoryMin <- function( _categoryID )
	{
	}

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
		this.m.PerkTree = ::new("scripts/dpf/perk_tree");
		this.m.PerkTree.setBackground(this);
		this.m.PerkTree.onDeserialize(_in);
	}
});
