var DynamicPerksJSConnection = function(_parent)
{
    MSUBackendConnection.call(this);
    this.mModID = DynamicPerks.ID;
    this.mID = DynamicPerks.JSConnectionID;
}

DynamicPerksJSConnection.prototype = Object.create(MSUBackendConnection.prototype);
Object.defineProperty(DynamicPerksJSConnection.prototype, 'constructor', {
    value: DynamicPerksJSConnection,
    enumerable: false,
    writable: true
});

DynamicPerksJSConnection.prototype.updatePerkToGroupPerksMap = function (_groupPerkIDs)
{
	DynamicPerks.PerkToGroupPerksMap[_groupPerkIDs[0]] = _groupPerkIDs;
}

registerScreen(DynamicPerks.JSConnectionID, new DynamicPerksJSConnection());
