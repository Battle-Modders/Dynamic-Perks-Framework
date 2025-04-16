::DynamicPerks.HooksMod.hook("scripts/skills/skill", function (q) {
	q.m.IsRefundable <- true;

	q.isRefundable <- function()
	{
		return this.m.IsRefundable && this.m.IsSerialized;
	}

	q.getPerkGroupMultiplier <- function( _groupID, _perkTree )
	{
		return 1.0;
	}

	q.isPerkUnlockable <- function( _perkID, _tooltip )
	{
		return true;
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
