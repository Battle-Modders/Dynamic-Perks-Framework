::DynamicPerks <- {
	Version = "0.2.1",
	ID = "mod_dynamic_perks",
	Name = "Dynamic Perks Framework (DPF)",
	GitHubURL = "https://github.com/Battle-Modders/Dynamic-Perks-Framework",
	VeryLateBucket = []
};

::DynamicPerks.HooksMod <- ::Hooks.register(::DynamicPerks.ID, ::DynamicPerks.Version, ::DynamicPerks.Name);
::DynamicPerks.HooksMod.require("mod_msu");

::DynamicPerks.HooksMod.queue(">mod_msu", function() {

	::DynamicPerks.Mod <- ::MSU.Class.Mod(::DynamicPerks.ID, ::DynamicPerks.Version, ::DynamicPerks.Name);

	::DynamicPerks.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::DynamicPerks.GitHubURL);
	::DynamicPerks.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::include("dynamic_perks/load.nut");
	::Hooks.registerJS("ui/mods/mod_dynamic_perks/setup.js");
	::Hooks.registerJS("ui/mods/mod_dynamic_perks/generic_perks_module.js");
	::Hooks.registerCSS("ui/mods/mod_dynamic_perks/generic_perks_module.css");
	::Hooks.registerJS("ui/mods/mod_dynamic_perks/generic_perkgroups_module.js");
	::Hooks.registerCSS("ui/mods/mod_dynamic_perks/generic_perkgroups_module.css");

	foreach(file in this.IO.enumerateFiles("ui/mods/mod_dynamic_perks/hooks"))
	{
		::Hooks.registerJS(file + ".js");
	}
});

::DynamicPerks.HooksMod.queue(">mod_msu", function() {
	foreach (func in ::DynamicPerks.VeryLateBucket)
	{
		func();
	}
	::DynamicPerks.VeryLateBucket = null;
}, ::Hooks.QueueBucket.VeryLate)

::DynamicPerks.HooksMod.queue(">mod_msu", function() {
	local tooltipImageKeywords = {};
	foreach (perkGroup in ::DynamicPerks.PerkGroups.getAll())
	{
		if (perkGroup.getIcon() == "")
			continue;
		tooltipImageKeywords[perkGroup.getIcon()] <- "PerkGroup+" + perkGroup.getID();
	}
	::DynamicPerks.Mod.Tooltips.setTooltipImageKeywords(tooltipImageKeywords);
}, ::Hooks.QueueBucket.AfterHooks);
