::DPF <- {
	Version = "0.1.0",
	ID = "mod_dpf",
	Name = "Dynamic Perks Framework (DPF)"
};

::mods_registerMod(::DPF.ID, ::DPF.Version, ::DPF.Name);
::mods_queue(::DPF.ID, "mod_msu", function() {

	::includeFiles(::IO.enumerateFiles("scripts/dpf"));
	::mods_registerJS("dpf_mod_screens.js");

	::MSU.EndQueue.add(function() {
		::Const.Perks.Categories.sort();
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

	::Const.Perks.addPerkGroup("TestPerkGroup", "TestPerkGroup", ["test perk group"], [
		["perk.test"],
		["perk.duelist"]
	])

	local dynamicMap = {
		Weapon = [
			"TestPerkGroup"
		]
	};

	::Const.Perks.addCategory("Weapon", "Weapon", "Has an aptitude for", 1, [
		"TestPerkGroup"
	]);

	::Const.Perks.addCategory("Style", "Style", "Likes using");
	// ::Const.Perks.Categories.findById("Style").setPlayerSpecificFunction( function (_player ) {
	// 	local hasRangedWeaponGroup = false;
	// 	local hasMeleeWeaponGroup = false;

	// 	foreach (perkGroup in ::Const.Perks.PerkGroupsCollection.RangedWeapon.getList())
	// 	{
	// 		if (_player.getBackground().getPerkTree().hasPerkGroup(perkGroup))
	// 		{
	// 			hasRangedWeaponGroup = true;
	// 			break;
	// 		}
	// 	}

	// 	foreach (perkGroup in ::Const.Perks.PerkGroupsCollection.MeleeWeapon.getList())
	// 	{
	// 		if (_player.getBackground().getPerkTree().hasPerkGroup(perkGroup))
	// 		{
	// 			hasMeleeWeaponGroup = true;
	// 			break;
	// 		}
	// 	}

	// 	if (!hasRangedWeaponGroup) _player.getBackground().m.Multipliers["RangedStyle"] <- 0;
	// 	if (!hasMeleeWeaponGroup)
	// 	{
	// 		_player.getBackground().m.Multipliers["OneHandedStyle"] <- 0;
	// 		_player.getBackground().m.Multipliers["TwoHandedStyle"] <- 0;
	// 	}
	// });

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
