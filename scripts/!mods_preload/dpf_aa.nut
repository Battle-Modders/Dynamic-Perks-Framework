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

	// Testing

	::Const.Perks.LookupMap["perk.test"] <- {
		ID = "perk.test",
		Script = "scripts/skills/perks/perk_fast_adaption",
		Name = "Test Perk",
		Tooltip = "Let\'s test this perk",
		Icon = "ui/perks/perk_33.png",
		IconDisabled = "ui/perks/perk_33_sw.png"
	};

	::DPF.Perks.PerkGroups.add(::new(::DPF.Class.PerkGroup).init("TestPerkGroup", "TestPerkGroup", ["test perk group"], [
		["perk.reach_advantage"],
		["perk.test"]
	]));

	local dynamicMap = {
		Weapon = [
			"TestPerkGroup"
		]
	};

	::DPF.Perks.PerkGroupCategories.add(::new(::DPF.Class.PerkGroupCollection).init("Weapon", "Weapon", "Has an aptitude for", 1, [
		"TestPerkGroup"
	]));

	::DPF.Perks.PerkGroupCategories.add(::new(::DPF.Class.PerkGroupCollection).init("Style", "Style", "Likes using"));

	::DPF.MyPerkGroupCollections <- {};
	::DPF.Perks.PerkGroupCategories["RangedWeapon"] <- ::new(::DPF.Class.PerkGroupCollection).init("RangedWeapon", "RangedWeapon");
	::DPF.Perks.PerkGroupCategories["MeleeWeapon"] <- ::new(::DPF.Class.PerkGroupCollection).init("MeleeWeapon", "MeleeWeapon");

	::DPF.Perks.PerkGroupCategories.findById("Style").getSpecialMultipliers = function( _perkTree ) {
		local multipliers = {};

		if (_perkTree.numPerkGroupsFromCollection(::DPF.MyPerkGroupCollections.RangedWeapon) == 0)
		{
			multipliers["RangedStyle"] <- 0;
		}

		if (_perkTree.numPerkGroupsFromCollection(::DPF.MyPerkGroupCollections.MeleeWeapon) == 0)
		{
			multipliers["OneHandedStyle"] <- 0;
			multipliers["OneHandedStyle"] <- 0;
		}

		return multipliers;
	};

	::mods_hookNewObject("skills/backgrounds/companion_1h_background", function(o) {
		o.m.PerkTree = ::new(::DPF.Class.PerkTree).init(null, {});
		o.onBuildPerkTree <- function()
		{
			this.getPerkTree().addPerk("perk.duelist", 5);
		}

		local getTooltip = o.getTooltip;
		o.getTooltip <- function()
		{
			local ret = getTooltip();
			ret.push({
				id = 7,
				type = "text",
				icon = "ui/icons/special.png",
				text = this.getPerkTree().getTooltip()
			});
			ret.push({
				id = 7,
				type = "text",
				icon = "ui/icons/special.png",
				text = this.getPerkTree().getPerksTooltip()
			});

			return ret;
		}
	});
});
