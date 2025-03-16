::DynamicPerks.HooksMod.hook("scripts/scenarios/world/starting_scenario", function (q) {
	q.onBuildPerkTree <- function( _perkTree )
	{
	}

	// A return of `null` is considered 1.0
	q.getPerkGroupMultiplier <- function( _groupID, _perkTree )
	{
	}
});
