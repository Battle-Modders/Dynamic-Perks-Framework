::DynamicPerks.Tests <- {
	// Logs the probability that a newly generated bro with the given background has a perk tree for which _successFunc(perkTree) returns true.
	// Results depend on the current campaign origin, because the origin is a perk group multiplier source.
	function printProbability( _backgroundFilename, _successFunc, _iterations = 1000 )
	{
		local successes = [0]; // array so that the callback modifies the same counter
		local elapsed = this.__simulate(_backgroundFilename, _iterations, function( _perkTree ) {
			if (_successFunc(_perkTree))
				successes[0]++;
		});

		::logInfo(format("%s, success: %.1f%% (%s)", this.__getHeader(_backgroundFilename, _iterations, elapsed), 100.0 * successes[0] / _iterations, this.__getMarginText(_iterations)));
	}

	// Logs for every perk group the probability that a newly generated bro with the given background has it, grouped by perk group category.
	// Results depend on the current campaign origin, because the origin is a perk group multiplier source.
	function printProbability_All( _backgroundFilename, _iterations = 1000 )
	{
		// A perk group can be listed in several categories (and a special perk group in a category), so each ID is
		// listed only once: under the first category in order of assignment that contains it.
		local seen = {};
		local sections = [];
		local addSection = function( _name, _ids )
		{
			local ids = [];
			foreach (id in _ids)
			{
				if (id in seen)
					continue;
				seen[id] <- true;
				ids.push(id);
			}
			ids.sort();
			sections.push({ Name = _name, IDs = ids });
		};

		foreach (category in ::DynamicPerks.PerkGroupCategories.getOrdered())
		{
			addSection(category.getName(), category.getGroups());
		}
		addSection("Special", ::DynamicPerks.PerkGroups.getByType(::DynamicPerks.Class.SpecialPerkGroup).map(@(_pg) _pg.getID()));

		local perkGroupIDs = [];
		foreach (section in sections)
		{
			perkGroupIDs.extend(section.IDs);
		}

		local successes = array(perkGroupIDs.len(), 0);
		local elapsed = this.__simulate(_backgroundFilename, _iterations, function( _perkTree ) {
			foreach (i, pgID in perkGroupIDs)
			{
				if (_perkTree.hasPerkGroup(pgID))
					successes[i]++;
			}
		});

		local probabilities = {};
		foreach (i, pgID in perkGroupIDs)
		{
			probabilities[pgID] <- successes[i].tofloat() / _iterations;
		}

		::logInfo(this.__getHeader(_backgroundFilename, _iterations, elapsed) + " (" + this.__getMarginText(_iterations) + ")");
		foreach (section in sections)
		{
			if (section.IDs.len() == 0)
				continue;

			local mean = 0.0;
			foreach (pgID in section.IDs)
			{
				mean += probabilities[pgID];
			}
			::logInfo(format("== %s (mean number of groups: %.2f)", section.Name, mean));

			foreach (pgID in section.IDs)
			{
				::logInfo(format("%s: %.1f%%", pgID, 100.0 * probabilities[pgID]));
			}
		}
	}

	// Generates _iterations bros of the given background and calls _onPerkTree(perkTree) for each.
	// Returns the elapsed time in seconds.
	// Limitation: one background instance is reused, so a background that randomizes something in create() keeps that roll for all bros.
	function __simulate( _backgroundFilename, _iterations, _onPerkTree )
	{
		local bro = this.__getPlayerForProbability();
		local bg = this.__getBackgroundForProbability(_backgroundFilename);
		local path = "scripts/skills/backgrounds/" + _backgroundFilename;
		local bgArray = [_backgroundFilename];

		local originalNew = ::new;
		::new = @( _script ) _script == path ? bg : originalNew(_script);

		local startTime = ::Time.getExactTime();
		try
		{
			for (local i = 0; i < _iterations; i++)
			{
				// DynamicPerks' setStartValuesEx hook creates and builds the perk tree
				bro.setStartValuesEx(bgArray);
				_onPerkTree(bro.getPerkTree());
			}
		}
		catch (error)
		{
			::new = originalNew;
			::World.getTemporaryRoster().remove(bro);
			throw error;
		}
		local elapsed = ::Time.getExactTime() - startTime;

		::new = originalNew;
		::World.getTemporaryRoster().remove(bro);

		return elapsed;
	}

	function __getHeader( _backgroundFilename, _iterations, _elapsed )
	{
		local origin = "none";
		if ("Assets" in ::World && !::MSU.isNull(::World.Assets) && !::MSU.isNull(::World.Assets.getOrigin()))
			origin = ::World.Assets.getOrigin().getID();

		return format("Perk group probabilities of %s: %i bros, origin %s, %i ms", _backgroundFilename, _iterations, origin, (_elapsed * 1000).tointeger());
	}

	// Worst-case (p = 50%) margin of error at 95% confidence
	function __getMarginText( _iterations )
	{
		return format("95%% margin at most +-%.1f pp", 100.0 * 1.96 * sqrt(0.25 / _iterations));
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
			// Reset the bro for the next roll. Skills are cleared directly without onRemoved, which is fine for this test.
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
		bg.setAppearance = @() null;
		bg.buildDescription = @( _isFinal = false ) null;
		return bg;
	}
};
