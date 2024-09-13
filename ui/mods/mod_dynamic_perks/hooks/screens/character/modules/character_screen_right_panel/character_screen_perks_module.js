DynamicPerks.Hooks.CharacterScreenPerksModule_loadPerkTreesWithBrotherData = CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData;
CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData = function (_brother)
{
	this.resetPerkTree(this.mPerkTree);
	this.onPerkTreeLoaded(null, _brother.perkTree);
	DynamicPerks.Hooks.CharacterScreenPerksModule_loadPerkTreesWithBrotherData.call(this, _brother);
};

CharacterScreenPerksModule.prototype.initPerkTree = function (_perkTree, _perksUnlocked)
{
	var self = this;
	var perkTier = this.mDataSource.getBrotherPerkTier(this.mDataSource.getSelectedBrother());
	var lockedPerks = this.mDataSource.getLockedPerks(this.mDataSource.getSelectedBrother());

	for (var row = 0; row < this.mPerkRows.length; ++row)
	{
		this.mPerkRows[row].addClass('is-unlocked').removeClass('is-locked');
	}

	for (var row = 0; row < _perkTree.length; ++row)
	{
		for (var i = 0; i < _perkTree[row].length; ++i)
		{
			var perk = _perkTree[row][i];
			var perkGroupOverlay = $('<div class="dynamicperks-image-overlay"/>');
			perk.Container.append(perkGroupOverlay);
			perk.PerkGroupOverlay = perkGroupOverlay;
			var imageLayer = perk.Container.find('.perk-image-layer:first')
			if (row >= perkTier)
			{
				imageLayer.addClass('is-locked').removeClass('is-unlocked');
			}

			for (var j = 0; j < lockedPerks.length; ++j)
			{
				if (lockedPerks[j] == perk.ID)
				{
					imageLayer.addClass('is-locked').removeClass('is-unlocked');
				}
			}

			for (var j = 0; j < _perksUnlocked.length; ++j)
			{
				if(_perksUnlocked[j] == perk.ID)
				{
					perk.Unlocked = true;

					perk.Image.attr('src', Path.GFX + perk.Icon);

					var selectionLayer = perk.Container.find('.selection-image-layer:first');
					selectionLayer.removeClass('display-none').addClass('display-block');

					imageLayer.addClass('is-unlocked').removeClass('is-locked');

					break;
				}
			}
		}
	}
};

DynamicPerks.Hooks.CharacterScreenPerksModule_attachEventHandler = CharacterScreenPerksModule.prototype.attachEventHandler;
CharacterScreenPerksModule.prototype.attachEventHandler = function(_perk)
{
	DynamicPerks.Hooks.CharacterScreenPerksModule_attachEventHandler.call(this, _perk);
	var self = this;
	_perk.Container.attr('tabindex', 0);

	_perk.Container.on('mouseenter.dynamicperks', null, this, function (_event)
	{
		_perk.Container.focus();
	});
	_perk.Container.on('mouseleave.dynamicperks keyup.dynamicperks', null, this, function (_event)
	{
		if (!MSU.getSettingValue(DynamicPerks.ID, "PerkTree_HighlightPerkGroups")) return;

		$.each(self.mPerkTree, function(_, _row)
		{
			$.each(_row, function(__, _innerPerk){
				_innerPerk.PerkGroupOverlay.css("border", "none");
			})
		})
	});
	_perk.Container.on('keydown.dynamicperks', null, this, function (_event)
	{
		if (!MSU.getSettingValue(DynamicPerks.ID, "PerkTree_HighlightPerkGroups"))
			return;
		if (!MSU.Keybinds.isKeybindPressed(DynamicPerks.ID, "PerkTree_HighlightPerkGroups_keybind", _event))
			return;
		Screens.Tooltip.getModule('TooltipModule').hideTooltip();
		// this iterates through the perks once for each perkgroup, but honestly it's not very many perks and this allows us to cut out a bunch of code
		$.each(_perk.PerkGroupIDs, function(_idx, _id){
			$.each(self.mPerkTree, function(_, _row){
				$.each(_row, function(__, _innerPerk){
					if (_perk ==_innerPerk || _innerPerk.PerkGroupIDs.indexOf(_id) == -1) return;
					_innerPerk.PerkGroupOverlay.css("border", "2px solid " + DynamicPerks.PerkGroupColors[_idx]);
				})
			})
		})
	});
	_perk.Container.on('keyup.dynamicperks', null, this, function (_event)
	{
		_perk.Image.trigger("mouseenter");
	})
};

DynamicPerks.Hooks.CharacterScreenPerksModule_removePerksEventHandler = CharacterScreenPerksModule.prototype.removePerksEventHandler;
CharacterScreenPerksModule.prototype.removePerksEventHandler = function (_perkTree)
{
	DynamicPerks.Hooks.CharacterScreenPerksModule_removePerksEventHandler.call(this, _perkTree);
	for (var row = 0; row < _perkTree.length; ++row)
	{
		for (var i = 0; i < _perkTree[row].length; ++i)
		{
			var perk = _perkTree[row][i];
			perk.Container.off(".dynamicperks");
		}
	}
};


CharacterScreenDatasource.prototype.getBrotherPerkTier = function (_brother)
{
	if (_brother === null || !(CharacterScreenIdentifier.Entity.Character.Key in _brother))
	{
		return 0;
	}

	var character = _brother[CharacterScreenIdentifier.Entity.Character.Key];
	if (character === null)
	{
		return 0;
	}

	if (CharacterScreenIdentifier.Entity.Character.PerkPoints in character)
	{
		var perkTier = _brother.perkTier;
		if (perkTier !== null && typeof (perkTier) == 'number')
		{
			return perkTier;
		}
	}

	return 0;
};

CharacterScreenDatasource.prototype.getLockedPerks = function (_brother)
{
	if (_brother === null || !(CharacterScreenIdentifier.Entity.Character.Key in _brother))
	{
		return 0;
	}

	var character = _brother[CharacterScreenIdentifier.Entity.Character.Key];
	if (character === null)
	{
		return 0;
	}

	if (CharacterScreenIdentifier.Entity.Character.PerkPoints in character)
	{
		var lockedPerks = _brother.lockedPerks;
		if (lockedPerks !== null)
		{
			return lockedPerks;
		}
	}

	return null;
};

CharacterScreenPerksModule.prototype.isPerkUnlockable = function (_perk)
{
	var perkPoints = this.mDataSource.getBrotherPerkPoints(this.mDataSource.getSelectedBrother());
	var perkTier = this.mDataSource.getBrotherPerkTier(this.mDataSource.getSelectedBrother());
	var lockedPerks = this.mDataSource.getLockedPerks(this.mDataSource.getSelectedBrother());

	if (perkPoints > 0 && perkTier >= _perk.Row + 1)
	{
		for (var i = 0; i < lockedPerks.length; ++i)
		{
			if (_perk.ID === lockedPerks[i])
			{
				return false;
			}
		}
		return true;
	}

	return false;
};
