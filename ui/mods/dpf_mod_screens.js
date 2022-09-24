var DynamicPerksFramework = {};
DynamicPerksFramework.loadPerkTreesWithBrotherData = CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData;
CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData = function (_brother)
{
	this.resetPerkTree(this.mPerkTree);
	this.onPerkTreeLoaded(null, _brother.perkTree);
	DynamicPerksFramework.loadPerkTreesWithBrotherData.call(this, _brother);
};

CharacterScreenPerksModule.prototype.setupPerksEventHandlers = function(_perkTree)
{
	this.removePerksEventHandlers();

	for (var row = 0; row < _perkTree.length; ++row)
	{
		for (var i = 0; i < _perkTree[row].length; ++i)
		{
			var perk = _perkTree[row][i];
			// perk.Unlocks = row;
			this.attachEventHandler(perk);
		}
	}
};

CharacterScreenPerksModule.prototype.isPerkUnlockable = function (_perk)
{
	var perkPoints = this.mDataSource.getBrotherPerkPoints(this.mDataSource.getSelectedBrother());
	// var perkPointsSpent = this.mDataSource.getBrotherPerkPointsSpent(this.mDataSource.getSelectedBrother());
	var perkTier = this.mDataSource.getBrotherPerkTier(this.mDataSource.getSelectedBrother());

	console.error('bro perk tier: ' + perkTier + ' and ' + _perk.ID + ' tier is ' + _perk.Tier + ' and unlocks is ' + _perk.Unlocks);
	if(perkPoints > 0 && perkTier >= _perk.Unlocks)
	{
		return true;
	}

	return false;
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
		var perkPoints = _brother.perkTier;
		if (perkPoints !== null && typeof (perkPoints) == 'number')
		{
			return perkPoints;
		}
	}

	return 0;
};

CharacterScreenPerksModule.prototype.initPerkTree = function (_perkTree, _perksUnlocked)
{
	// var perkPointsSpent = this.mDataSource.getBrotherPerkPointsSpent(this.mDataSource.getSelectedBrother());
	var perkPointsSpent = this.mDataSource.getBrotherPerkTier(this.mDataSource.getSelectedBrother());

	for (var row = 0; row < _perkTree.length; ++row)
	{
		for (var i = 0; i < _perkTree[row].length; ++i)
		{
			var perk = _perkTree[row][i];

			for (var j = 0; j < _perksUnlocked.length; ++j)
			{
				if(_perksUnlocked[j] == perk.ID)
				{
					perk.Unlocked = true;

					perk.Image.attr('src', Path.GFX + perk.Icon);

					var selectionLayer = perk.Container.find('.selection-image-layer:first');
					selectionLayer.removeClass('display-none').addClass('display-block');

					break;
				}
			}

			/*if(perk.Row <= perkPointsSpent)
			{
				var selectionLayer = perk.Container.find('.selection-image-layer:first');
				selectionLayer.removeClass('display-none').addClass('display-block');
			}*/
		}
	}

	for (var row = 0; row < this.mPerkRows.length; ++row)
	{
		if (row <= perkPointsSpent)
		{
			this.mPerkRows[row].addClass('is-unlocked').removeClass('is-locked');
		}
		else
		{
			break;
		}
	}
};
