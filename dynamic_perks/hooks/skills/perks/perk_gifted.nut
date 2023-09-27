::DynamicPerks.HooksMod.hook("scripts/skills/perks/perk_gifted", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.IsRefundable = false;
	}
});
