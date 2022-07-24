::DPF <- {
	Version = "0.1.0",
	ID = "mod_dpf",
	Name = "Dynamic Perks Framework (DPF)"
};

::mods_registerMod(::DPF.ID, ::DPF.Version, ::DPF.Name);
::mods_queue(::DPF.ID, "mod_msu", function() {

	::DPF.Mod <- ::MSU.Class.Mod(::DPF.ID, ::DPF.Version, ::DPF.Name);

	::includeFiles(::IO.enumerateFiles("scripts/dpf"));
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

	::DPF.Perks.PerkGroups.add(::new("scripts/dpf/perk_group").init("TestPerkGroup", "TestPerkGroup", ["test perk group"], [
		["perk.reach_advantage"],
		["perk.duelist"]
	]));

	local dynamicMap = {
		Weapon = [
			"TestPerkGroup"
		]
	};

	::DPF.Perks.PerkGroupCategories.add(::new("scripts/dpf/perk_group_collection").init("Weapon", "Weapon", "Has an aptitude for", 1, [
		"TestPerkGroup"
	]));

	::DPF.Perks.PerkGroupCategories.add(::new("scripts/dpf/perk_group_collection").init("Style", "Style", "Likes using"));

	::DPF.MyPerkGroupCollections <- {};
	::DPF.Perks.PerkGroupCategories["RangedWeapon"] <- ::new("scripts/dpf/perk_group_collection").init("RangedWeapon", "RangedWeapon");
	::DPF.Perks.PerkGroupCategories["MeleeWeapon"] <- ::new("scripts/dpf/perk_group_collection").init("MeleeWeapon", "MeleeWeapon");

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
		o.m.PerkTree = ::new("scripts/dpf/perk_tree").init(null, {});
		o.onBuildPerkTree <- function()
		{
			this.getPerkTree().addPerk("perk.test", 5);
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
