::DPF.Class <- {
	PerkGroup = "scripts/mods/mod_dpf/classes/perk_group",
	PerkGroupCollection = "scripts/mods/mod_dpf/classes/perk_group_collection",
	PerkTree = "scripts/mods/mod_dpf/classes/perk_tree",
	SpecialPerk = "scripts/mods/mod_dpf/classes/special_perk"
};

::includeFiles(::IO.enumerateFiles("dpf/hooks"));
::include("dpf/config.nut");
