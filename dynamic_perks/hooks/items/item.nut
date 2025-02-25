::DynamicPerks.HooksMod.hook("scripts/items/item", function(q) {
	q.getPerkGroupMultiplier <- function( _groupID, _perkTree )
	{
		return 1.0;
	}
});
