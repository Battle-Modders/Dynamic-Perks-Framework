::DPF <- {};
::DPF.Version = "0.1.0";
::DPF.ID = "mod_dpf";
::DPF.Name = "Dynamic Perks Framework (DPF)";

::mods_registerMod(::DPF.ID, ::DPF.Version, ::DPF.Name);
::mods_queue(::DPF.ID, "mod_msu", function() {

	::MSU.EndQueue.add(function() {
		::Const.Perks.Category.sort(function( _key1, _value1, _key2, _value2 ) {
			return _value1.OrderOfAssignment <=> _value2.OrderOfAssignment;
		});
	})

	// Testing

	::Const.Perks.addCategory("Weapon");
	::Const.Perks.addCategory("MeleeWeapon");
	::Const.Perks.addCategory("RangedWeapon");
	::Const.Perks.addCategory("Style");
	::Const.Perks.Category.Style.setPlayerSpecificFunction( function (_player ) {
		local hasRangedWeaponGroup = false;
		local hasMeleeWeaponGroup = false;

		foreach (perkGroup in ::Const.Perks.PerkGroupCollection.RangedWeapon.getList())
		{
			if (_player.getBackground().getPerkTree().hasPerkGroup(perkGroup, true))
			{
				hasRangedWeaponGroup = true;
				break;
			}
		}

		foreach (perkGroup in ::Const.Perks.PerkGroupCollection.MeleeWeapon.getList())
		{
			if (_player.getBackground().getPerkTree().hasPerkGroup(perkGroup, true))
			{
				hasMeleeWeaponGroup = true;
				break;
			}
		}

		if (!hasRangedWeaponGroup) _player.getBackground().m.PerkGroupMultipliers.push([0, ::Const.Perks.PerkGroup.RangedStyles]);
		if (!hasMeleeWeaponGroup)
		{
			_player.getBackground().m.PerkGroupMultipliers.push([0, ::Const.Perks.OneHandedStyles]);
			_player.getBackground().m.PerkGroupMultipliers.push([0, ::Const.Perks.TwoHandedStyles]);
		}
	});
});
