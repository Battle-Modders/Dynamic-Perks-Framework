::DynamicPerks.Tests <- {
	function printProbability( _backgroundFilename, _successFunc )
	{
		local bro = this.__getPlayerForProbability();
		local bg = this.__getBackgroundForProbability(_backgroundFilename);
		local path = "scripts/skills/backgrounds/" + _backgroundFilename;

		local new = ::new;
		::new = @( _script ) _script == path ? bg : new(_script);

		for (local i = 0; i < 300; i++)
		{
			bro.setStartValuesEx(_backgroundFilename);
			bro.m.PerkTree = bro.getBackground().createPerkTreeBlueprint();
			bro.m.PerkTree.setActor(bro);
			bro.m.PerkTree.build();
			pT = bro.getPerkTree();
			if (_successFunc(pT))
			{
				successes++;
			}
		}

		::new = new;

		::World.getTemporaryRoster().remove(bro);

		::logInfo(successes / _iterations);
	}

	function printProbability_All( _backgroundFilename )
	{
		local perkGroupIDs = [];
		foreach (category in ::DynamicPerks.PerkGroupCategories.getOrdered())
		{
			local ids = clone category.getGroups();
			ids.sort();
			perkGroupIDs.extend(ids);
		}

		local successes = array(perkGroupIDs.len(), 0.0);

		local bro = this.__getPlayerForProbability();
		local bg = this.__getBackgroundForProbability(_backgroundFilename);
		local path = "scripts/skills/backgrounds/" + _backgroundFilename;

		local new = ::new;
		::new = @( _script ) _script == path ? bg : new(_script);

		local pT;

		local bgArray = [_backgroundFilename];
		local iterations = 300;

		for (local i = 0; i < iterations; i++)
		{
			bro.setStartValuesEx(bgArray);
			bro.m.PerkTree = bro.getBackground().createPerkTreeBlueprint();
			bro.m.PerkTree.setActor(bro);
			bro.m.PerkTree.build();
			pT = bro.getPerkTree();
			foreach (i, pgID in perkGroupIDs)
			{
				if (pT.hasPerkGroup(pgID))
				{
					successes[i]++;
				}
			}
		}

		::new = new;

		::World.getTemporaryRoster().remove(bro);

		foreach (i, pgID in perkGroupIDs)
		{
			::logInfo(pgID + ": " + (successes[i] / iterations));
		}
	}

	function __getPlayerForProbability()
	{
		local bro = ::World.getTemporaryRoster().create("scripts/entity/tactical/player");

		bro.setTitle = function( _value )
		{
		}

		bro.setFaction = function( _f )
		{
		}

		bro.fillAttributeLevelUpValues = function( _amount, _maxOnly = false, _minOnly = false )
		{
		}

		local setStartValuesEx = bro.setStartValuesEx;
		bro.setStartValuesEx = function( _backgroundFilename )
		{
			this.getSkills().m.Skills.clear();
			this.getItems().clear();
			this.m.Talents.clear();
			this.m.Attributes.clear();

			setStartValuesEx(_backgroundFilename);
		}

		return bro;
	}

	function __getBackgroundForProbability( _backgroundFilename )
	{
		local bg = ::new("scripts/skills/backgrounds/" + _backgroundFilename);
		bg.buildDescription = @() null;
		bg.setAppearance = @() null;
		bg.buildDescription = @( _isFinal = false ) null;
		return bg;
	}
};


