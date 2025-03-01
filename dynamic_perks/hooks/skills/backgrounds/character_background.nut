::DynamicPerks.HooksMod.hook("scripts/skills/backgrounds/character_background", function(q) {
	q.m.PerkTree <- null;

	q.create = @(__original) function()
	{
		this.m.PerkTree = ::new(::DynamicPerks.Class.PerkTree).init({Template = ::DynamicPerks.DefaultPerkTreeTemplate});
		__original();
	}

	q.onBuildPerkTree <- function()
	{
	}

	q.getPerkGroupCollectionMin <- function( _collection )
	{
	}
});
