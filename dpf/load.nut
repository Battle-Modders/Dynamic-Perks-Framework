::DPF.Class <- {
	PerkGroup = "dpf/classes/perk_group",
	PerkGroupCollection = "dpf/classes/perk_group_collection",
	PerkTree = "dpf/classes/perk_tree",
	SpecialPerk = "dpf/classes/special_perk"
};

::includeFiles(::IO.enumerateFiles("dpf/classes"));
::includeFiles(::IO.enumerateFiles("dpf/hooks"));
::include("dpf/config.nut");
