::DynamicPerks.HooksMod.hook("scripts/skills/skill_container", function (q) {
	q.isPerkUnlockable <- function( _perkID, _tooltip )
	{
		local ret = true;
		local wasUpdating = this.m.IsUpdating;
		this.m.IsUpdating = true;

		foreach (s in this.m.Skills)
		{
			if (!s.isGarbage())
			{
				ret = s.isPerkUnlockable(_perkID, _tooltip) && ret;
			}
		}

		this.m.IsUpdating = wasUpdating;
		return ret;
	}
});
