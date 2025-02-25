::DynamicPerks.Tests <- {
	function printProbability( _backgroundFilename, _perkGroups, _numRequired = null, _iterations = 300 )
	{
		if (_numRequired == null)
			_numRequired = _perkGroups.len();

		if (_perkGroups.len() == 0)
			throw "_perkGroups must be an array with at least one element";

		if (_numRequired > _perkGroups.len())
			throw "_numRequired must be equal to or less than _perkGroups array length";

		local bgArray = [_backgroundFilename];
		local roster = ::World.getTemporaryRoster();
		local successes = 0.0;
		local bro, pT;

		for (local i = 0; i < _iterations; i++)
		{
			bro = roster.create("scripts/entity/tactical/player");
			bro.setStartValuesEx(bgArray);
			pT = bro.getPerkTree();
			foreach (pgID in _perkGroups)
			{
				if (pT.hasPerkGroup(pgID))
				{
					successes++;
				}
			}
			roster.remove(bro);
		}

		::logInfo(successes / _iterations);
	}

	function printProbability_All( _backgroundFilename, _iterations = 300 )
	{
		local perkGroupIDs = ::MSU.Table.keys(::DynamicPerks.PerkGroups.getAll());
		perkGroupIDs.sort(@(_a, _b) _a <=> _b);

		local successes = array(perkGroupIDs.len(), 0.0);

		local bgArray = [_backgroundFilename];
		local roster = ::World.getTemporaryRoster();
		local bro, pT;

		for (local i = 0; i < _iterations; i++)
		{
			bro = roster.create("scripts/entity/tactical/player");
			bro.setStartValuesEx(bgArray);
			pT = bro.getPerkTree();
			foreach (i, pgID in perkGroupIDs)
			{
				if (pT.hasPerkGroup(pgID))
				{
					successes[i]++;
				}
			}
			roster.remove(bro);
		}

		foreach (i, pgID in perkGroupIDs)
		{
			::logInfo(pgID + ": " + (successes[i] / _iterations));
		}
	}
};
