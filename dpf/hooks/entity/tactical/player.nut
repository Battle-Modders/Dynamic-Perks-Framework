::mods_hookExactClass("entity/tactical/player", function (o) {
	local isPerkUnlockable = o.isPerkUnlockable;
	o.isPerkUnlockable = function( _id )
	{
		if (isPerkUnlockable(_id))
		{
			return this.getBackground().getPerkTree().isPerkUnlockable(_id);
		}

		return false;
	}

	local setStartValuesEx = o.setStartValuesEx;
	o.setStartValuesEx = function( _backgrounds, _addTraits = true )
	{
		setStartValuesEx(_backgrounds, _addTraits);
		this.getBackground().getPerkTree().build();
	}

	o.resetPerks <- function()
	{
		// Get all items that are adding skills to this character and unequip them to remove those skills
		// Necessary, as some items may add perks
		local items = this.getItems().getAllItems().filter(@(idx, item) item.getSkills().len() != 0);
		foreach (item in items)
		{
			this.getItems().unequip(item);
		}

		local skills = this.getSkills().getSkillsByFunction(@(skill) skill.isType(::Const.SkillType.Perk) && skill.isRefundable());
		foreach (skill in skills)
		{
			skill.removeSelf();
			this.m.PerkPoints++;
			this.m.PerkPointsSpent--;
		}

		this.getSkills().update();

		// Re-equip the items
		foreach (item in items)
		{
			this.getItems().equip(item);
		}
	}
});
