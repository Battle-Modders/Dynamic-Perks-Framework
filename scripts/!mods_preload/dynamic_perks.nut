::DynamicPerks <- {
	Version = "0.3.0",
	ID = "mod_dynamic_perks",
	Name = "Dynamic Perks Framework (DPF)",
	GitHubURL = "https://github.com/Battle-Modders/Dynamic-Perks-Framework",
	NexusModsURL = "https://www.nexusmods.com/battlebrothers/mods/758",
	QueueBucket = {
		VeryLate = [],
		AfterHooks = []
	}
};

::DynamicPerks.HooksMod <- ::Hooks.register(::DynamicPerks.ID, ::DynamicPerks.Version, ::DynamicPerks.Name);
::DynamicPerks.HooksMod.require([
	"mod_msu",
	"mod_nested_tooltips"
]);

::DynamicPerks.HooksMod.queue(">mod_msu", function() {

	::DynamicPerks.Mod <- ::MSU.Class.Mod(::DynamicPerks.ID, ::DynamicPerks.Version, ::DynamicPerks.Name);

	::DynamicPerks.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::DynamicPerks.GitHubURL);
	::DynamicPerks.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, ::DynamicPerks.NexusModsURL);
	::DynamicPerks.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::DynamicPerks.Mod.Debug.enable();

	::DynamicPerks.Mod.Keybinds.addSQKeybind("CloseOverviewScreen", "escape", ::MSU.Key.State.All,	function()
		{
			if (::DynamicPerks.OverviewScreen.isVisible())
			{
				::DynamicPerks.OverviewScreen.hide();
				return true;
			};
		}, "Close Overview Screen").setBypassInputDenied(true);


	::include("dynamic_perks/load.nut");
	::Hooks.registerJS("ui/mods/mod_dynamic_perks/setup.js");
	::Hooks.registerJS("ui/mods/mod_dynamic_perks/generic_perks_module.js");
	::Hooks.registerCSS("ui/mods/mod_dynamic_perks/generic_perks_module.css");
	::Hooks.registerJS("ui/mods/mod_dynamic_perks/generic_perkgroups_module.js");
	::Hooks.registerCSS("ui/mods/mod_dynamic_perks/generic_perkgroups_module.css");

	::Hooks.registerJS("ui/mods/mod_dynamic_perks/hooks/screens/character/modules/character_screen_right_panel/character_screen_perks_module.js");
	::Hooks.registerCSS("ui/mods/mod_dynamic_perks/hooks/screens/character/modules/character_screen_right_panel/character_screen_perks_module.css");

	::Hooks.registerJS("ui/mods/mod_dynamic_perks/screens/dpf_perk_overview_screen.js");
	::Hooks.registerCSS("ui/mods/mod_dynamic_perks/screens/dpf_perk_overview_screen.css");
	::DynamicPerks.OverviewScreen <- ::new("scripts/ui/screens/dpf_perk_overview_screen");
	::MSU.UI.registerConnection(::DynamicPerks.OverviewScreen);
});

::DynamicPerks.HooksMod.queue(">mod_msu", function() {
	foreach (func in ::DynamicPerks.QueueBucket.VeryLate)
	{
		func();
	}
}, ::Hooks.QueueBucket.VeryLate)

::DynamicPerks.HooksMod.queue(">mod_msu", function() {
	foreach (func in ::DynamicPerks.QueueBucket.AfterHooks)
	{
		func();
	}

	foreach (perk in ::Const.Perks.LookupMap)
	{
		perk.PerkGroupIDs <- [];
	}

	local tooltipImageKeywords = {};
	foreach (perkGroup in ::DynamicPerks.PerkGroups.getAll())
	{
		foreach (row in perkGroup.getTree())
		{
			foreach (perkID in row)
			{
				::Const.Perks.findById(perkID).PerkGroupIDs.push(perkGroup.getID());
			}
		}
		if (perkGroup.getIcon() != "")
		{
			tooltipImageKeywords[perkGroup.getIcon()] <- "PerkGroup+" + perkGroup.getID();
		}
	}
	::DynamicPerks.Mod.Tooltips.setTooltipImageKeywords(tooltipImageKeywords);

	delete ::DynamicPerks.QueueBucket;
}, ::Hooks.QueueBucket.AfterHooks);
