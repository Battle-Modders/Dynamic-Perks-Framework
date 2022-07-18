::mods_hookExactClass("scripts/entity/tactical/player", function (o) {
	local isPerkUnlockable = o.isPerkUnlockable;
	o.isPerkUnlockable = function( _id )
	{
		if (isPerkUnlockable(_id))
		{
			local perk = this.getBackground().getPerkTree().getPerk(_id);
			if (perk != null && this.m.PerkPointsSpent >= perk.Unlocks) return true;
		}

		return false;
	}

	local setStartValuesEx = o.setStartValuesEx;
	o.setStartValuesEx = function( _backgrounds, _addTraits = true )
	{
		setStartValuesEx(_backgrounds, _addTraits);
		this.getBackground().getPerkTree().build();
	}
});
