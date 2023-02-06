"use strict";

DynamicPerks.GenericPerkGroupsModule = function(_parentDiv, _displayType)
{
	// container
	this.mContainer = null;
	_displayType = _displayType || 0;

    this.mContentContainer = null;
    this.mDisplayTypes = {
    	Unordered : 0,
    	Ordered : 1
    }
    this.mDisplayType = _displayType;

    // perks
    this.mPerkGroups = null;
    this.mPerkGroupObjects = [];
    this.createDIV(_parentDiv)
};

DynamicPerks.GenericPerkGroupsModule.prototype.createDIV = function (_parentDiv)
{
	this.mContainer = $('<div class="generic-perkgroups-module"/>')
		.appendTo(_parentDiv);

    this.mContentContainer = $('<div class="generic-perkgroups-content-container unordered"/>')
    	.appendTo(this.mContainer);
};

DynamicPerks.GenericPerkGroupsModule.prototype.destroyDIV = function ()
{
    this.mContentContainer.remove();
    this.mContentContainer = null;

    this.mContainer.remove();
    this.mContainer = null;

    this.mDisplayType = this.mDisplayTypes.Unordered;
    this.mPerkGroupObjects = [];
};

DynamicPerks.GenericPerkGroupsModule.prototype.setDisplayType = function (_idx)
{
    var oldDisplayType = this.mDisplayType;
    this.mDisplayType = _idx;
    if (oldDisplayType !== this.mDisplayType)
    {
    	this.setupContainerDiv();
    }
};

DynamicPerks.GenericPerkGroupsModule.prototype.createOrderedPerkGroupsDIV = function ()
{
	// Enduriel wants to refactor this
	this.mContentContainer.removeClass("unordered").addClass("ordered");

	for (var row = 0; row < this.mPerkGroups.length; ++row)
	{
		var rowDIV = $('<div class="perks-row"/>')
			.appendTo(this.mContentContainer);

		for (var i = 0; i < this.mPerkGroups[row].length; ++i)
		{
			this.addPerkGroupDIV(this.mPerkGroups[row][i], rowDIV);
		}
	}
};

DynamicPerks.GenericPerkGroupsModule.prototype.createUnorderdPerkGroupsDIV = function ()
{
	this.mContentContainer.removeClass("ordered").addClass("unordered");
	for (var row = 0; row < this.mPerkGroups.length; ++row)
	{
		this.addPerkGroupDIV(this.mPerkGroups[row], this.mContentContainer);
	}
}

DynamicPerks.GenericPerkGroupsModule.prototype.addPerkGroupDIV = function(_perkGroup, _parentDiv)
{
	this.mPerkGroupObjects.push(_perkGroup);
	_perkGroup.Container = $('<div class="l-perk-container"/>')
		.appendTo(_parentDiv);

	var tooltipID = "PerkGroup+" + _perkGroup.ID;
	_perkGroup.Image = $('<img class="perk-image-layer"/>')
		.attr('src', Path.GFX + _perkGroup.Icon)
		.appendTo(_perkGroup.Container)
		.bindTooltip({ contentType: 'msu-generic', modId: "mod_dpf", elementId: tooltipID });

}

DynamicPerks.GenericPerkGroupsModule.prototype.setupContainerDiv = function ()
{
	// Enduriel wants to refactor this
    this.mContentContainer.empty();
    this.mPerkGroupObjects = [];
    if (this.mDisplayType === this.mDisplayTypes.Unordered)
    	this.createUnorderdPerkGroupsDIV();
    else this.createOrderedPerkGroupsDIV();
};

DynamicPerks.GenericPerkGroupsModule.prototype.loadFromData = function (_perkGroups)
{
	if (_perkGroups === undefined || _perkGroups === null)
		return;
    this.mPerkGroups = _perkGroups;
    this.setupContainerDiv();
};
