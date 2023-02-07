::mods_hookExactClass("skills/backgrounds/character_background", function (o) {
	o.m.PerkTreeMultipliers <- {};
	o.m.PerkTree <- ::new(::DynamicPerks.Class.PerkTree).init({Template = ::DynamicPerks.Perks.DefaultPerkTreeTemplate});

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
