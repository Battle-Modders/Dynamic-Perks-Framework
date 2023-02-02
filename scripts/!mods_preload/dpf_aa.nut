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
	::mods_registerJS("mod_dpf/setup.js");
	::mods_registerJS("mod_dpf/generic_perks_module.js");
	::mods_registerCSS("mod_dpf/generic_perks_module.css");

	local prefixLen = "ui/mods/".len();
	foreach(file in this.IO.enumerateFiles("ui/mods/mod_dpf/hooks"))
	{
		file = file.slice(prefixLen) + ".js";
		::mods_registerJS(file);
	}
});
