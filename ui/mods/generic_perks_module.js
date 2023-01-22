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
	// create: containers (init hidden!)
	this.mContainer = $('<div class="generic-perks-module"/>');
	_parentDiv.append(this.mContainer);

    // create rows
    this.mTreeContainer = $('<div class="perks-tree"/>');
    this.mContainer.append(this.mTreeContainer);
};

GenericPerksModule.prototype.destroyDIV = function ()
{
    this.mTreeContainer.empty();
    this.mTreeContainer.remove();
    this.mTreeContainer = null;

    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
};


GenericPerksModule.prototype.createPerkTreeDIV = function (_perkTree, _parentDiv)
{
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
	for (var row = 0; row < this.mPerkTree.length; ++row)
	{
		for (var i = 0; i < this.mPerkTree[row].length; ++i)
		{
			var perk = this.mPerkTree[row][i];
			perk.Image.unbindTooltip();
			if (_entityID !== undefined && _entityID !== null)
				perk.Image.bindTooltip({ contentType: 'ui-perk', entityId: _entityID, perkId: perk.ID });
			else
				perk.Image.bindTooltip({ contentType: 'msu-generic', modId: "mod_dpf", elementId: "Perks.GenericTooltip", perkID : perk.ID})
		}
	}
};

GenericPerksModule.prototype.setupPerkTree = function ()
{
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

