CharacterScreenIdentifier.Perk.Tree = 'perkTree';

CharacterScreenDatasource.prototype.queryPerkInformation = function(_perkId, _background, _callback)
{
	this.notifyBackendQueryPerkInformation(_perkId, _background, _callback);
};

CharacterScreenDatasource.prototype.notifyBackendQueryPerkInformation = function (_perkId, _background, _callback)
{
	SQ.call(this.mSQHandle, 'onQueryPerkInformation', [_perkId, _background], _callback);
};

CharacterScreenPerksModule.prototype.resetPerkTree = function(_perkTree)
{
	if (_perkTree == null)
		return;

	this.mPerkTree = _perkTree;

	for (var row = 0; row < this.mPerkRows.length; ++row)
	{
		this.mPerkRows[row].removeClass('is-unlocked').addClass('is-locked');
	}

	for (var row = 0; row < _perkTree.length; ++row)
	{
		for (var i = 0; i < _perkTree[row].length; ++i)
		{
			var perk = _perkTree[row][i];
			console.error(Object.keys(perk));
			perk.Unlocked = false;

			perk.Image.attr('src', Path.GFX + perk.IconDisabled);

			var selectionLayer = perk.Container.find('.selection-image-layer:first');
			selectionLayer.addClass('display-none').removeClass('display-block');
		}
	}
};

CharacterScreenPerksModule.prototype.setupPerkTree = function (_perkTree)
{
	if (this.mPerkTree !== null) {
		this.removePerksEventHandlers()
	}
	this.mLeftColumn.empty();
	this.mPerkTree = _perkTree;
	this.createPerkTreeDIV(this.mPerkTree, this.mLeftColumn);

	this.setupPerksEventHandlers(this.mPerkTree);
};

CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData = function (_brother)
{
	this.setupPerkTree(_brother[CharacterScreenIdentifier.Perk.Tree]);

	if (CharacterScreenIdentifier.Perk.Key in _brother)
	{
		this.initPerkTree(this.mPerkTree, _brother[CharacterScreenIdentifier.Perk.Key]);
	}

	if (CharacterScreenIdentifier.Entity.Id in _brother)
	{
		this.setupPerkTreeTooltips(this.mPerkTree, _brother[CharacterScreenIdentifier.Entity.Id]);
	}
};

CharacterScreenPerksModule.prototype.isPerkUnlockable = function (_perk)
{
	var _brother = this.mDataSource.getSelectedBrother();
	var character = _brother[CharacterScreenIdentifier.Entity.Character.Key];
	var level = character[CharacterScreenIdentifier.Entity.Character.Level];
	var perkPoints = this.mDataSource.getBrotherPerkPoints(_brother);
	var perkPointsSpent = this.mDataSource.getBrotherPerkPointsSpent(_brother);

	if(level >= 13 && _perk.ID === 'perk.student') {
		return false;
	}
	return perkPoints > 0 && perkPointsSpent >= _perk.Unlocks;
};

CharacterScreenPerksModule.prototype.setupPerksEventHandlers = function(_perkTree)
{
	//this.removePerksEventHandlers();

	for (var row = 0; row < _perkTree.length; ++row)
	{
		for (var i = 0; i < _perkTree[row].length; ++i)
		{
			var perk = _perkTree[row][i];
			this.attachEventHandler(perk);
		}
	}
};

CharacterScreenPerksModule.prototype.onPerkTreeLoaded = function (_dataSource, _perkTree)
{
	// if (_perkTree !== null)
	// {

	// 	this.mPerkTree = _perkTree;
	//	 this.setupPerkTree();
	// }
};
