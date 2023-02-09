::DynamicPerks <- {
	Version = "0.1.0",
	ID = "mod_dynamic_perks",
	Name = "Dynamic Perks Framework (DPF)",
	GitHubURL = "https://github.com/Battle-Modders/Dynamic-Perks-Framework"
};

::mods_registerMod(::DynamicPerks.ID, ::DynamicPerks.Version, ::DynamicPerks.Name);
::mods_queue(::DynamicPerks.ID, "mod_msu", function() {

	::DynamicPerks.Mod <- ::MSU.Class.Mod(::DynamicPerks.ID, ::DynamicPerks.Version, ::DynamicPerks.Name);

	::DynamicPerks.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::DynamicPerks.GitHubURL);
	::DynamicPerks.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::include("dynamic_perks/load.nut");
	::mods_registerJS("mod_dynamic_perks/setup.js");
	::mods_registerJS("mod_dynamic_perks/generic_perks_module.js");
	::mods_registerCSS("mod_dynamic_perks/generic_perks_module.css");
	::mods_registerJS("mod_dynamic_perks/generic_perkgroups_module.js");
	::mods_registerCSS("mod_dynamic_perks/generic_perkgroups_module.css");

	local prefixLen = "ui/mods/".len();
	foreach(file in this.IO.enumerateFiles("ui/mods/mod_dynamic_perks/hooks"))
	{
		file = file.slice(prefixLen) + ".js";
		::mods_registerJS(file);
	}
});
