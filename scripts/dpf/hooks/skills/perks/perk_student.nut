::mods_hookExactClass("skills/perks/perk_student", function (o) {
	o.onUpdateLevel <- function()
	{
		if (this.getContainer().getActor().getLevel() == 11)
		{
			this.m.IsRefundable = false;
		}
	}
});
