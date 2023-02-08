::mods_hookBaseClass("skills/skill", function (o) {
	o = o[o.SuperName];

	o.m.IsRefundable <- true;
	o.m.PerkTreeMultipliers <- {};

	o.isRefundable <- function()
	{
		return this.m.IsRefundable;
	}

	o.getPerkTreeMultipliers <- function()
	{
		return this.m.PerkTreeMultipliers;
	}

	local onSerialize = o.onSerialize;
	o.onSerialize = function( _out )
	{
		onSerialize(_out);
		_out.writeBool(this.m.IsRefundable);
	}

	local onDeserialize = o.onDeserialize;
	o.onDeserialize = function( _in )
	{
		onDeserialize(_in);
		this.m.IsRefundable = _in.readBool();
	}
});
