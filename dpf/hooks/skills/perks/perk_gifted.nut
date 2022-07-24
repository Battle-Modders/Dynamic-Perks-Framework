::mods_hookExactClass("skills/perks/perk_gifted", function (o) {
	local create = o.create;
	o.create = function()
	{
		create();
		this.m.IsRefundable = false;
	}
});
