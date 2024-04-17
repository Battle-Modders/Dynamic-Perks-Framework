::DynamicPerks.HooksMod.hook("scripts/skills/skill", function (q) {
	q.m.IsRefundable <- true;
	q.m.PerkTreeMultipliers <- {};

	q.isRefundable <- function()
	{
		return this.m.IsRefundable && this.m.IsSerialized;
	}

	q.getPerkTreeMultipliers <- function()
	{
		return this.m.PerkTreeMultipliers;
	}

	q.onSerialize = @(__original) function( _out )
	{
		__original(_out);
		_out.writeBool(this.m.IsRefundable);
	}

	q.onDeserialize = @(__original) function( _in )
	{
		__original(_in);
		this.m.IsRefundable = _in.readBool();
	}
});
