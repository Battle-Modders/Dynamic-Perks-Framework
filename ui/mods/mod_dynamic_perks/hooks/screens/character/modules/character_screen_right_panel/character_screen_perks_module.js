DynamicPerks.Hooks.CharacterScreenPerksModule_createDIV = CharacterScreenPerksModule.prototype.createDIV;
CharacterScreenPerksModule.prototype.createDIV = function (_parentDiv)
{
	DynamicPerks.Hooks.CharacterScreenPerksModule_createDIV.call(this, _parentDiv);
	this.mPerkGroups = {};
	this.mPerkGroupColors = ["rgba(255,234,125,0.5)", "blue", "red", "green", "purple", "orange", "teal", "cyan"];
}

DynamicPerks.Hooks.CharacterScreenPerksModule_destroyDIV = CharacterScreenPerksModule.prototype.destroyDIV;
CharacterScreenPerksModule.prototype.destroyDIV = function ()
{
	DynamicPerks.Hooks.CharacterScreenPerksModule_destroyDIV.call(this);
	this.mPerkGroups = {};
}

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
	this.mPerkGroups = {};

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
			$.each(perk.PerkGroupIDs, function(_idx, _id){
				if (_id in self.mPerkGroups) {
					self.mPerkGroups[_id].push(perk);
				}
				else {
					self.mPerkGroups[_id] = [perk];
				}
			})
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
	var mouseOn = false;

	_perk.Container.on('mouseenter.dynamicperks focus.dynamicperks' + CharacterScreenIdentifier.KeyEvent.PerksModuleNamespace, null, this, function (_event)
	{
		mouseOn = true;
	});

	_perk.Container.on('mouseleave.dynamicperks blur.dynamicperks' + CharacterScreenIdentifier.KeyEvent.PerksModuleNamespace, null, this, function (_event)
	{
		mouseOn = false;
		if (!MSU.getSettingValue(DynamicPerks.ID, "PerkTree_HighlightPerkGroups")) return;

		$.each(_perk.PerkGroupIDs, function(_idx, _id){
			$.each(self.mPerkGroups[_id], function(_, _perk){
				_perk.PerkGroupOverlay.css("border", "none");
			})
		})
	});

	$(document).on('keydown.dynamicperks' + CharacterScreenIdentifier.KeyEvent.PerksModuleNamespace, null, this, function (_event)
	{
		if (!mouseOn)
			return;
		if (!MSU.getSettingValue(DynamicPerks.ID, "PerkTree_HighlightPerkGroups"))
			return;
		if (!MSU.Keybinds.isKeybindPressed(DynamicPerks.ID, "PerkTree_HighlightPerkGroups_keybind", _event))
			return;
		Screens.Tooltip.getModule('TooltipModule').hideTooltip();
		$.each(_perk.PerkGroupIDs, function(_idx, _id){
			$.each(self.mPerkGroups[_id], function(_, _innerPerk){
				if (_perk ==_innerPerk) return;
				_innerPerk.PerkGroupOverlay.css("border", "2px solid " + self.mPerkGroupColors[_idx]);
			})
		})
	});
}

DynamicPerks.Hooks.CharacterScreenPerksModule_removePerksEventHandler = CharacterScreenPerksModule.prototype.removePerksEventHandler;
CharacterScreenPerksModule.prototype.removePerksEventHandler = function (_perkTree)
{
	DynamicPerks.Hooks.CharacterScreenPerksModule_removePerksEventHandler.call(this, _perkTree);
	for (var row = 0; row < _perkTree.length; ++row)
	{
		for (var i = 0; i < _perkTree[row].length; ++i)
		{
			var perk = _perkTree[row][i];
			perk.Container.off("dynamicperks");
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
