::mods_hookExactClass("entity/tactical/player", function (o) {
	o.m.PerkTree <- ::DynamicPerks.getDefaultPerkTree();
	o.m.PerkTier <- ::DynamicPerks.Const.DefaultPerkTier;

	o.getPerkTree <- function()
	{
		return this.m.PerkTree;
	}

	o.getPerkTier <- function()
	{
		return this.m.PerkTier;
	}

	o.setPerkTier <- function( _perkTier )
	{
		this.m.PerkTier = _perkTier;
	}

	o.resetPerkTier <- function()
	{
		this.setPerkTier(::DynamicPerks.Const.DefaultPerkTier + this.getPerkPointsSpent());
	}

	o.isPerkUnlockable = function( _id )
	{
		if (this.getPerkTier() < this.getPerkTree().getPerkTier(_id))
			return false;

		local perk = this.getPerkTree().getPerk(_id);
		if ((::MSU.isIn("verifyPrerequisites", perk, true)) && !perk.verifyPrerequisites(this, [])) // TODO: Efficiency issue: passing an empty array every time
			return false;

		return true;
	}

	local unlockPerk = o.unlockPerk;
	o.unlockPerk = function( _id )
	{
		local ret = unlockPerk( _id );
		if (ret) this.setPerkTier(this.getPerkTier() + 1);
		return ret;
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

		this.resetPerkTier();
		
		this.getSkills().update();

		// Re-equip the items
		foreach (item in items)
		{
			this.getItems().equip(item);
		}
	}

	local onSerialize = o.onSerialize;
	o.onSerialize = function( _out )
	{
		onSerialize(_out);
		_out.writeU8(this.m.PerkTier);
		this.m.PerkTree.onSerialize(_out);
	}

	local onDeserialize = o.onDeserialize;
	o.onDeserialize = function( _in )
	{
		onDeserialize(_in);
		// TEMPORARY: This is to fix an issue in Reforged with the Weapon Master perk.
		// The permanent fix is to do PerkTree serialization before original onDeserialize function
		// But that will break saves, so we do this for now.
		local weapon = this.getMainhandItem();
		if (weapon != null) this.getItems().unequip(weapon);

		this.m.PerkTier = _in.readU8();
		this.m.PerkTree = ::new(::DynamicPerks.Class.PerkTree);
		this.m.PerkTree.setActor(this);
		this.m.PerkTree.onDeserialize(_in);

		if (weapon != null) this.getItems().equip(weapon);
	}
});

::MSU.EndQueue.add(function() {
	::mods_hookExactClass("entity/tactical/player", function(o) {
		local setStartValuesEx = o.setStartValuesEx;
		o.setStartValuesEx = function( _backgrounds, _addTraits = true )
		{
			setStartValuesEx(_backgrounds, _addTraits);
			this.m.PerkTree = this.getBackground().m.PerkTree;
			this.m.PerkTree.setActor(this);
			this.m.PerkTree.build();
		}
	});
});
