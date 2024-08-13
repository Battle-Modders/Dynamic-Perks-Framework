::DynamicPerks.HooksMod.hook("scripts/items/misc/potion_of_oblivion_item", function(q) {
	q.onUse = @() function( _actor, _item = null )
	{
		::Sound.play("sounds/combat/drink_03.wav", ::Const.Sound.Volume.Inventory);

		_actor.resetPerks();

		::Const.Tactical.Common.checkDrugEffect(_actor);
		::updateAchievement("MemoryLoss", 1, 1);
		return true;
	}
});
