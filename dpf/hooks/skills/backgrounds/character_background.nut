::mods_hookExactClass("skills/backgrounds/character_background", function (o) {
	o.m.PerkTreeMultipliers <- {};
	o.m.PerkTree <- ::new(::DPF.Class.PerkTree).init({Template = ::DPF.Perks.DefaultPerkTreeTemplate});

	o.onBuildPerkTree <- function()
	{
	}

	o.getCollectionMin <- function( _collectionID )
	{
	}

	o.getPerkTreeMultipliers <- function()
	{
		return this.m.PerkTreeMultipliers;
	}
});
