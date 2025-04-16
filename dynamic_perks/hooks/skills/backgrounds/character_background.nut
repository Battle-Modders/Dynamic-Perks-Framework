::DynamicPerks.HooksMod.hook("scripts/skills/backgrounds/character_background", function(q) {
	q.createPerkTreeBlueprint <- function()
	{
		return ::new(::DynamicPerks.Class.PerkTree).init({Template = ::DynamicPerks.DefaultPerkTreeTemplate});
	}

	q.onBuildPerkTree <- function()
	{
	}

	q.getPerkGroupCollectionMin <- function( _collection )
	{
	}
});
