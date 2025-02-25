::DynamicPerks.Class <- {
	PerkGroup = "scripts/mods/mod_dynamic_perks/classes/perk_group",
	PerkGroupCollection = "scripts/mods/mod_dynamic_perks/classes/perk_group_collection",
	PerkTree = "scripts/mods/mod_dynamic_perks/classes/perk_tree",
	SpecialPerkGroup = "scripts/mods/mod_dynamic_perks/classes/special_perk_group"
};

foreach (file in ::IO.enumerateFiles("dynamic_perks/hooks"))
{
	::include(file);
}
::include("dynamic_perks/config.nut");
::include("dynamic_perks/dynamic_perks_tooltips.nut");
::include("dynamic_perks/mod_settings.nut");
::include("dynamic_perks/keybinds.nut");
::include("dynamic_perks/tests.nut");
