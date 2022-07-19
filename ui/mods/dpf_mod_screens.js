var DynamicPerksFramework = {};
DynamicPerksFramework.loadPerkTreesWithBrotherData = CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData;
CharacterScreenPerksModule.prototype.loadPerkTreesWithBrotherData = function (_brother)
{
	this.resetPerkTree(this.mPerkTree);
	this.onPerkTreeLoaded(null, _brother.perkTree);
	DynamicPerksFramework.loadPerkTreesWithBrotherData.call(this, _brother);
};
