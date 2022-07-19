// character_screen_identifier.js
var DynamicPerks = {};

// character_screen_perks_module.js

DynamicPerks.loadPerkTreesWithBrotherData = CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData;
CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData = function (_brother)
{
	this.resetPerkTree(this.mPerkTree);
	this.onPerkTreeLoaded(null, _brother.perkTree);
	DynamicPerks.loadPerkTreesWithBrotherData.call(this, _brother);
};
