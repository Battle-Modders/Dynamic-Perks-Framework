var DynamicPerksOverviewScreen = function ()
{
	MSUUIScreen.call(this);
	this.mActiveModule   = null;
	this.mModules = {
		"PerksModule" : {
			Container : null,
			Module : null
		},
        "PerkGroupsModule" : {
			Container : null,
			Module : null
		},
    }
};

DynamicPerksOverviewScreen.prototype = Object.create(MSUUIScreen.prototype);
Object.defineProperty(DynamicPerksOverviewScreen.prototype, 'constructor', {
	value: DynamicPerksOverviewScreen,
	enumerable: false,
	writable: true
});

DynamicPerksOverviewScreen.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
    this.createModules();
};

DynamicPerksOverviewScreen.prototype.createDIV = function(_parentDiv)
{
	this.mContainer = $("<div class='dpf-overview-screen'/>")
		.appendTo(_parentDiv);

	this.mModuleContainer  = $('<div class="dpf-overview-module-container"/>');
	this.mContainer.append(this.mModuleContainer)

	var footer = $('<div class="dpf-overview-footer"/>')
		.appendTo(this.mContainer);
    this.mLeaveButton = footer.createTextButton("Leave", $.proxy(function()
	{
        this.onLeaveButtonPressed();
    }, this));
};

DynamicPerksOverviewScreen.prototype.createModules = function()
{
	this.mModules.PerksModule.Container = $("<div class='dpf-overview-perks-container'/>")
		.append($("<div class='name title-font-normal font-bold font-color-brother-name'>Perks</div>"))
		.hide()
		.appendTo(this.mContainer);

	this.mModules.PerkGroupsModule.Container = $("<div class='dpf-overview-perkgroups-container'/>")
		.append($("<div class='name title-font-normal font-bold font-color-brother-name'>Perk Groups</div>"))
		.hide()
		.appendTo(this.mContainer);

	this.mModules.PerksModule.Module = new DynamicPerks.GenericPerksModule(this.mModules.PerksModule.Container);
	this.mModules.PerkGroupsModule.Module = new DynamicPerks.GenericPerkGroupsModule(this.mModules.PerkGroupsModule.Container, 1);
}

registerScreen("DynamicPerksOverviewScreen", new DynamicPerksOverviewScreen());
