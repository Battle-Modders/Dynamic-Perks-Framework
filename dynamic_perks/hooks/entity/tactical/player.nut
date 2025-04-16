::DynamicPerks.HooksMod.hook("scripts/entity/tactical/player", function(q) {
	q.m.PerkTree <- null;
	q.m.PerkTier <- ::DynamicPerks.Const.DefaultPerkTier;

	q.create = @(__original) function()
	{
		this.m.PerkTree = ::DynamicPerks.getDefaultPerkTree();
		__original();
	}

	q.getPerkTree <- function()
	{
		return this.m.PerkTree;
	}

	q.getPerkTier <- function()
	{
		return this.m.PerkTier;
	}

	q.setPerkTier <- function( _perkTier )
	{
		this.m.PerkTier = _perkTier;
	}

	q.resetPerkTier <- function()
	{
		this.setPerkTier(::DynamicPerks.Const.DefaultPerkTier + this.getPerkPointsSpent());
	}

	q.isPerkUnlockable = @() function( _id )
	{
		if (this.getPerkTier() < this.getPerkTree().getPerkTier(_id))
			return false;

		// The tooltip is pointless here but the functions expect it so we pass an empty array
		local tooltip = [];
		local ret = this.getPerkTree().getPerk(_id).isUnlockable(this, tooltip);
		return this.getSkills().isPerkUnlockable(_id, tooltip) && ret;
	}

	q.unlockPerk = @(__original) function( _id )
	{
		local ret = __original( _id );
		if (ret) this.setPerkTier(this.getPerkTier() + 1);
		return ret;
	}

	q.resetPerks <- function()
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
		this.m.PerkPointsSpent = ::Math.max(0, this.m.PerkPointsSpent);		// If this goes into the negatives because something added refundable perks, then the PerkTier will be negative

		this.resetPerkTier();

		local skillsBefore;
		do
		{
			skillsBefore = this.getSkills().m.Skills.len();
			this.getSkills().collectGarbage(false);
		}
		while (this.getSkills().m.Skills.len() < skillsBefore);

		this.getSkills().update();

		// Re-equip the items
		foreach (item in items)
		{
			this.getItems().equip(item);
		}
	}

	q.onSerialize = @(__original) function( _out )
	{
		_out.writeU8(this.m.PerkTier);
		this.m.PerkTree.onSerialize(_out);
		__original(_out);
	}

	q.onDeserialize = @(__original) function( _in )
	{
		this.m.PerkTier = _in.readU8();
		this.m.PerkTree = ::new(::DynamicPerks.Class.PerkTree);
		this.m.PerkTree.setActor(this);
		this.m.PerkTree.onDeserialize(_in);
		__original(_in);
	}
});

::DynamicPerks.QueueBucket.VeryLate.push(function() {
	::DynamicPerks.HooksMod.hook("scripts/entity/tactical/player", function(q) {
		q.setStartValuesEx = @(__original) function( _backgrounds, _addTraits = true )
		{
			__original(_backgrounds, _addTraits);
			this.m.PerkTree = this.getBackground().createPerkTreeBlueprint();
			this.m.PerkTree.setActor(this);
			this.m.PerkTree.build();
		}
	});
});
