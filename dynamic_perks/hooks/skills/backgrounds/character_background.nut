::mods_hookExactClass("skills/backgrounds/character_background", function (o) {
	o.m.PerkTreeMultipliers <- {};
	o.m.PerkTree <- ::DynamicPerks.Class.PerkTree({Template = ::DynamicPerks.DefaultPerkTreeTemplate});

	o.onBuildPerkTree <- function()
	{
	}

	o.getCollectionMin <- function( _collectionID )
	{
	}
});
