::mods_hookExactClass("entity/tactical/player", function (o) {
	o.m.PerkTier <- ::DPF.Const.DefaultPerkTier;

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
		this.setPerkTier(::DPF.Const.DefaultPerkTier + this.getPerkPointsSpent());
	}

	o.isPerkUnlockable = function( _id )
	{
		return this.getPerkTier() >= this.getBackground().getPerkTree().getPerkTier(_id);
	}

	local unlockPerk = o.unlockPerk;
	o.unlockPerk = function( _id )
	{
		local ret = unlockPerk( _id );
		if (ret) this.setPerkTier(this.getPerkTier() + 1);
		return ret;
	}

	local setStartValuesEx = o.setStartValuesEx;
	o.setStartValuesEx = function( _backgrounds, _addTraits = true )
	{
		setStartValuesEx(_backgrounds, _addTraits);
		this.getBackground().getPerkTree().build();
		this.getSkills().add(::new("scripts/skills/perks/perk_reach_advantage"));
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
	function onSerialize( _out )
	{
		_out.writeU8(this.m.PerkTier);
		onSerialize(_out);
	}

	local onDeserialize = o.onDeserialize;
	function onDeserialize( _in )
	{
		this.m.PerkTier = _in.readU8();
		onDeserialize(_in);
	}
});

