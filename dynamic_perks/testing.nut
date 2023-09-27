::Const.Perks.LookupMap["perk.test"] <- {
	ID = "perk.test",
	Script = "scripts/skills/perks/perk_fast_adaption",
	Name = "Test Perk",
	Tooltip = "Let\'s test this perk",
	Icon = "ui/perks/perk_33.png",
	IconDisabled = "ui/perks/perk_33_sw.png"
};

::DynamicPerks.PerkGroups.add(::new(::DynamicPerks.Class.PerkGroup).init("TestPerkGroup", "TestPerkGroup", ["test perk group"], [
	["perk.reach_advantage"],
	["perk.test"]
]));

local dynamicMap = {
	Weapon = [
		"TestPerkGroup"
	]
};

::DynamicPerks.PerkGroupCategories.add(::new(::DynamicPerks.Class.PerkGroupCollection).init("Weapon", "Weapon", "Has an aptitude for", 1, [
	"TestPerkGroup"
]));

::DynamicPerks.PerkGroupCategories.add(::new(::DynamicPerks.Class.PerkGroupCollection).init("Style", "Style", "Likes using"));

::DynamicPerks.MyPerkGroupCollections <- {};
::DynamicPerks.PerkGroupCategories["RangedWeapon"] <- ::new(::DynamicPerks.Class.PerkGroupCollection).init("RangedWeapon", "RangedWeapon");
::DynamicPerks.PerkGroupCategories["MeleeWeapon"] <- ::new(::DynamicPerks.Class.PerkGroupCollection).init("MeleeWeapon", "MeleeWeapon");

::DynamicPerks.HooksMod.hook("scripts/skills/backgrounds/companion_1h_background", function(q) {
	q.m.PerkTree = ::new(::DynamicPerks.Class.PerkTree).init(null, {});
	q.onBuildPerkTree <- function()
	{
		this.getPerkTree().addPerk("perk.duelist", 5);
	}

	q.getTooltip <- @(__original) function()
	{
		local ret = __original();
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

::DynamicPerks.PerkGroupCategories.findById("Style").getSpecialMultipliers = function( _perkTree ) {
	local multipliers = {};

	if (_perkTree.numPerkGroupsFromCollection(::DynamicPerks.MyPerkGroupCollections.RangedWeapon) == 0)
	{
		multipliers["RangedStyle"] <- 0;
	}

	if (_perkTree.numPerkGroupsFromCollection(::DynamicPerks.MyPerkGroupCollections.MeleeWeapon) == 0)
	{
		multipliers["OneHandedStyle"] <- 0;
		multipliers["OneHandedStyle"] <- 0;
	}

	return multipliers;
};
