::mods_hookBaseClass("items/item", function (o) {
	o = o[o.SuperName];

	o.m.PerkTreeMultipliers <- {};

	o.getPerkTreeMultipliers <- function()
	{
		return this.m.PerkTreeMultipliers;
	}
});
