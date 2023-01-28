/*
 *  @Project:		Battle Brothers
 *	@Company:		Overhype Studios
 *  @Description:	Perks Module JS
 */
"use strict";


var GenericPerksModule = function(_parentDiv)
{
	// container
	this.mContainer = null;

    this.mTreeContainer = null;

    // perks
    this.mPerkTree = null;
    this.mPerkRows = [];
    this.createDIV(_parentDiv)
};


GenericPerksModule.prototype.createDIV = function (_parentDiv)
{
	this.mContainer = $('<div class="generic-perks-module"/>');
	_parentDiv.append(this.mContainer);

    this.mTreeContainer = $('<div class="perks-tree"/>');
    this.mContainer.append(this.mTreeContainer);
};

GenericPerksModule.prototype.destroyDIV = function ()
{
    this.mTreeContainer.remove();
    this.mTreeContainer = null;

    this.mContainer.remove();
    this.mContainer = null;
};


GenericPerksModule.prototype.createPerkTreeDIV = function (_perkTree, _parentDiv)
{
	// Enduriel wants to refactor this
	var self = this;

	for (var row = 0; row < _perkTree.length; ++row)
	{
		var rowDIV = $('<div class="perks-row"/>');
		_parentDiv.append(rowDIV);

		this.mPerkRows[row] = rowDIV;

		for (var i = 0; i < _perkTree[row].length; ++i)
		{
			var perk = _perkTree[row][i];
			perk.Unlocked = true;

			perk.Container = $('<div class="l-perk-container"/>');
			rowDIV.append(perk.Container);

			var perkSelectionImage = $('<img class="selection-image-layer display-none"/>');
			perkSelectionImage.attr('src', Path.GFX + Asset.PERK_SELECTION_FRAME);
			perk.Container.append(perkSelectionImage);

			perk.Image = $('<img class="perk-image-layer"/>');
			perk.Image.attr('src', Path.GFX + perk.Icon);
			perk.Container.append(perk.Image);
		}
	}
};

GenericPerksModule.prototype.setupPerkTreeTooltips = function(_entityID)
{
	// Enduriel probably wants to refactor this
	for (var row = 0; row < this.mPerkTree.length; ++row)
	{
		for (var i = 0; i < this.mPerkTree[row].length; ++i)
		{
			var perk = this.mPerkTree[row][i];
			perk.Image.unbindTooltip();
			perk.Image.bindTooltip({ contentType: 'ui-perk', entityId: _entityID || null, perkId: perk.ID });
		}
	}
};

GenericPerksModule.prototype.setupPerkTree = function ()
{
	// Enduriel wants to refactor this
    this.mTreeContainer.empty();
    this.createPerkTreeDIV(this.mPerkTree, this.mTreeContainer);
};

GenericPerksModule.prototype.loadFromData = function (_perkTree, _entityID)
{
	if (_perkTree === undefined || _perkTree === null)
		return;
    this.mPerkTree = _perkTree;
    this.setupPerkTree();
    this.setupPerkTreeTooltips(_entityID);
};

GenericPerksModule.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
};

GenericPerksModule.prototype.destroy = function()
{
    this.destroyDIV();
};

