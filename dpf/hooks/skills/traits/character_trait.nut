::mods_hookExactClass("skills/traits/character_trait", function (o) {
	o.m.PerkTreeMultipliers <- {};

	o.getPerkTreeMultipliers <- function()
	{
		return this.m.PerkTreeMultipliers;
	}
});
