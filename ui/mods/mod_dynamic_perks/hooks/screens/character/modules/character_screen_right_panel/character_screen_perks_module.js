DynamicPerks.Hooks.loadPerkTreesWithBrotherData = CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData;
CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData = function (_brother)
{
	this.resetPerkTree(this.mPerkTree);
	this.onPerkTreeLoaded(null, _brother.perkTree);
	DynamicPerks.Hooks.loadPerkTreesWithBrotherData.call(this, _brother);
};

CharacterScreenPerksModule.prototype.initPerkTree = function (_perkTree, _perksUnlocked)
{
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
