::mods_hookExactClass("skills/backgrounds/character_background", function (o) {
	o.m.PerkTreeMultipliers <- {};
	o.m.PerkTree <- ::new("scripts/dpf/perk_tree").init(::DPF.Perks.DefaultPerkTreeTemplate);

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

	o.getCollectionMin <- function( _collectionID )
	{
	}

	o.getPerkTreeMultipliers <- function()
	{
		return this.m.PerkTreeMultipliers;
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
