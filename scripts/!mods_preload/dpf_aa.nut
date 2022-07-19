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
		::Const.Perks.Category.sort(function( _key1, _value1, _key2, _value2 ) {
			return _value1.m.OrderOfAssignment <=> _value2.m.OrderOfAssignment;
		});
	})

	// Testing

	::mods_hookNewObject("skills/backgrounds/companion_1h_background", function(o) {
		o.onBuildPerkTree <- function()
		{
			::logInfo("removing Duelist");
			this.getPerkTree().removePerk("perk.duelist");
		}
	});

	::Const.Perks.addCategory("Weapon", "Weapon", "Has an aptitude for");
	::Const.Perks.addCategory("Style", "Style", "Likes using");
	::Const.Perks.Category.Style.setPlayerSpecificFunction( function (_player ) {
		local hasRangedWeaponGroup = false;
		local hasMeleeWeaponGroup = false;

		foreach (perkGroup in ::Const.Perks.PerkGroupCollection.RangedWeapon.getList())
		{
			if (_player.getBackground().getPerkTree().hasPerkGroup(perkGroup))
			{
				hasRangedWeaponGroup = true;
				break;
			}
		}

		foreach (perkGroup in ::Const.Perks.PerkGroupCollection.MeleeWeapon.getList())
		{
			if (_player.getBackground().getPerkTree().hasPerkGroup(perkGroup))
			{
				hasMeleeWeaponGroup = true;
				break;
			}
		}

		if (!hasRangedWeaponGroup) _player.getBackground().m.Multipliers["RangedStyle"] <- 0;
		if (!hasMeleeWeaponGroup)
		{
			_player.getBackground().m.Multipliers["OneHandedStyle"] <- 0;
			_player.getBackground().m.Multipliers["TwoHandedStyle"] <- 0;
		}
	});
});
