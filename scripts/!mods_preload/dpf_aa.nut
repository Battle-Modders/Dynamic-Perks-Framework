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

	::MSU.EndQueue.add(function() {
		::Const.Perks.PerkGroupCollections.sort();
	})

	// Testing

	::Const.Perks.LookupMap["perk.test"] <- {
		ID = "perk.test",
		Script = "scripts/skills/perks/perk_fast_adaption",
		Name = "Test Perk",
		Tooltip = "Let\'s test this perk",
		Icon = "ui/perks/perk_33.png",
		IconDisabled = "ui/perks/perk_33_sw.png"
	};

	::Const.Perks.PerkGroups.add("TestPerkGroup", "TestPerkGroup", ["test perk group"], [
		["perk.reach_advantage"],
		["perk.duelist"]
	])

	local dynamicMap = {
		Weapon = [
			"TestPerkGroup"
		]
	};

	::Const.Perks.PerkGroupCollections.add("Weapon", "Weapon", "Has an aptitude for", 1, [
		"TestPerkGroup"
	]);
	::Const.Perks.PerkGroupCollections.setUsedForPerkTree("Weapon");

	::Const.Perks.PerkGroupCollections.add("Style", "Style", "Likes using");
	::Const.Perks.PerkGroupCollections.setUsedForPerkTree("Style");

	::Const.Perks.PerkGroupCollections.add("RangedWeapon", "RangedWeapon");
	::Const.Perks.PerkGroupCollections.add("MeleeWeapon", "MeleeWeapon");

	::Const.Perks.PerkGroupCollections.findById("Style").getSpecialMultipliers = function( _perkTree ) {
		local multipliers = {};

		if (_perkTree.numPerkGroupsFromCollection(::Const.Perks.PerkGroupCollections.findById("RangedWeapon")) == 0)
		{
			multipliers["RangedStyle"] <- 0;
		}

		if (_perkTree.numPerkGroupsFromCollection(::Const.Perks.PerkGroupCollections.findById("MeleeWeapon")) == 0)
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
