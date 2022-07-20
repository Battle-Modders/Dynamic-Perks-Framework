::mods_hookBaseClass("skills/skill", function (o) {
	o = o[o.SuperName];

	o.m.IsRefundable <- true;

	o.isRefundable <- function()
	{
		return this.m.IsRefundable;
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
