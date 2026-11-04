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
		local sections = this.__getPerkGroupSections();
		local perkGroupIDs = this.__getPerkGroupIDs(sections);
		local result = this.__simulatePerkGroups(_backgroundFilename, _iterations, perkGroupIDs);
		local probabilities = {};
		foreach (i, pgID in perkGroupIDs)
		{
			probabilities[pgID] <- result.Probabilities[i];
		}

		::logInfo(this.__getHeader(_backgroundFilename, _iterations, result.Elapsed) + " (" + this.__getMarginText(_iterations) + ")");
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

	// Simulates every background that builds its perk tree from a DynamicMap and logs one CSV line per background,
	// prefixed with "DPF_CSV;" so the lines can be extracted from log.html. Columns: background, then the probability
	// (0-1) of every perk group, in the same order as printProbability_All. Backgrounds that throw are logged and skipped.
	// This blocks the game for a long time: about (number of backgrounds * _iterations * 2.5-6 ms).
	// Results depend on the current campaign origin, because the origin is a perk group multiplier source.
	function printProbability_AllBackgrounds( _iterations = 1000 )
	{
		local perkGroupIDs = this.__getPerkGroupIDs(this.__getPerkGroupSections());
		local backgrounds = this.__getDynamicBackgrounds();
		local startTime = ::Time.getExactTime();

		::logInfo(format("Perk group probabilities of %i backgrounds: %i bros each, origin %s (%s)", backgrounds.len(), _iterations, this.__getOriginID(), this.__getMarginText(_iterations)));
		::logInfo("DPF_CSV;background;" + perkGroupIDs.reduce(@(_a, _b) _a + ";" + _b));

		local failed = 0;
		foreach (filename in backgrounds)
		{
			try
			{
				local result = this.__simulatePerkGroups(filename, _iterations, perkGroupIDs);
				local line = "DPF_CSV;" + filename;
				foreach (p in result.Probabilities)
				{
					line += format(";%.4f", p);
				}
				::logInfo(line);
			}
			catch (error)
			{
				failed++;
				::logError("printProbability_AllBackgrounds: " + filename + " failed: " + error);
			}
		}

		::logInfo(format("printProbability_AllBackgrounds: %i backgrounds, %i failed, %i s", backgrounds.len(), failed, (::Time.getExactTime() - startTime).tointeger()));
	}

	// Filenames (relative to scripts/skills/backgrounds/) of all backgrounds whose perk tree blueprint uses a DynamicMap instead of a Template.
	function __getDynamicBackgrounds()
	{
		local prefix = "scripts/skills/backgrounds/";
		local ret = [];
		foreach (path in ::IO.enumerateFiles(prefix))
		{
			// The base class of all backgrounds, never a bro's actual background
			if (path == prefix + "character_background")
				continue;

			try
			{
				if (::new(path).createPerkTreeBlueprint().getTemplate() == null)
					ret.push(path.slice(prefix.len()));
			}
			catch (error)
			{
				::logError("printProbability_AllBackgrounds: can't create " + path + ": " + error);
			}
		}
		ret.sort();
		return ret;
	}

	// Perk group IDs grouped for output: one section per category in order of assignment, then "Special".
	// A perk group can be listed in several categories (and a special perk group in a category), so each ID is
	// listed only once: under the first category in order of assignment that contains it. IDs are sorted within a section.
	function __getPerkGroupSections()
	{
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

		return sections;
	}

	function __getPerkGroupIDs( _sections )
	{
		local ret = [];
		foreach (section in _sections)
		{
			ret.extend(section.IDs);
		}
		return ret;
	}

	// Returns { Probabilities = array of probabilities (0-1) in the order of _perkGroupIDs, Elapsed = seconds }
	function __simulatePerkGroups( _backgroundFilename, _iterations, _perkGroupIDs )
	{
		local successes = array(_perkGroupIDs.len(), 0);
		local elapsed = this.__simulate(_backgroundFilename, _iterations, function( _perkTree ) {
			foreach (i, pgID in _perkGroupIDs)
			{
				if (_perkTree.hasPerkGroup(pgID))
					successes[i]++;
			}
		});

		return {
			Probabilities = successes.map(@(_count) _count.tofloat() / _iterations),
			Elapsed = elapsed
		};
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

		// Every skill add and item equip during generation runs a full skills.update(). Only the final state matters,
		// so update does nothing during generation and runs once when DynamicPerks' setStartValuesEx hook asks for
		// the perk tree blueprint: that hook wraps all other mods' setStartValuesEx hooks, so generation is complete
		// and the perk tree has not been built yet. Mods that read current properties during generation would see stale ones.
		local skills = bro.getSkills();
		// bindenv: a stored method is not reliably bound to its object (e.g. hooked ones), so a plain call would run with this = bg
		local update = skills.update.bindenv(skills);
		skills.update = @() null;
		local createPerkTreeBlueprint = bg.createPerkTreeBlueprint.bindenv(bg);
		bg.createPerkTreeBlueprint = function()
		{
			update();
			bro.m.Hitpoints = bro.getCurrentProperties().Hitpoints; // as vanilla setStartValuesEx does after its update
			return createPerkTreeBlueprint();
		};

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
		return format("Perk group probabilities of %s: %i bros, origin %s, %i ms", _backgroundFilename, _iterations, this.__getOriginID(), (_elapsed * 1000).tointeger());
	}

	function __getOriginID()
	{
		if ("Assets" in ::World && !::MSU.isNull(::World.Assets) && !::MSU.isNull(::World.Assets.getOrigin()))
			return ::World.Assets.getOrigin().getID();
		return "none";
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
