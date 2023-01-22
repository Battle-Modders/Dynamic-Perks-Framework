::DPF.Class <- {
	PerkGroup = "scripts/mods/mod_dpf/classes/perk_group",
	PerkGroupCollection = "scripts/mods/mod_dpf/classes/perk_group_collection",
	PerkTree = "scripts/mods/mod_dpf/classes/perk_tree",
	SpecialPerkGroup = "scripts/mods/mod_dpf/classes/special_perk_group"
};

::includeFiles(::IO.enumerateFiles("dpf/hooks"));
::include("dpf/config.nut");
::include("dpf/tooltips.nut");
