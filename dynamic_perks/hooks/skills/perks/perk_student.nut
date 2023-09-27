::DynamicPerks.HooksMod.hook("scripts/skills/perks/perk_student", function(q) {
	q.onUpdateLevel <- function()
	{
		if (this.getContainer().getActor().getLevel() == 11)
		{
			this.m.IsRefundable = false;
		}
	}
});
