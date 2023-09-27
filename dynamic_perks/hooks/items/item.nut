::DynamicPerks.HooksMod.hook("scripts/items/item", function(q) {
	q.m.PerkTreeMultipliers <- {};

	q.getPerkTreeMultipliers <- function()
	{
		return this.m.PerkTreeMultipliers;
	}
});
