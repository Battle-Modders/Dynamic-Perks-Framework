::DPF <- {
	Version = "0.1.0",
	ID = "mod_dpf",
	Name = "Dynamic Perks Framework (DPF)",
};

::mods_registerMod(::DPF.ID, ::DPF.Version, ::DPF.Name);
::mods_queue(::DPF.ID, "mod_msu", function() {

	::DPF.Mod <- ::MSU.Class.Mod(::DPF.ID, ::DPF.Version, ::DPF.Name);

	// ::includeFiles(::IO.enumerateFiles("dpf"));
	::include("dpf/load.nut");
	::mods_registerJS("dpf_mod_screens.js");
	::mods_registerJS("generic_perks_module.js");
	::mods_registerCSS("generic_perks_module.css");
});
