var DynamicPerksOverviewScreen = function ()
{
	MSUUIScreen.call(this);
	//	{
	//      perkGroup::ID = {
	//	    	perkGroup = perkGroup::UIData,
	//	    	perks = [perk::UIData, ...]
	//		}
	//	}
	this.mPerkGroupCollectionData = null;
	this.mIsFirstLoad = true;
	this.mPerkFilterIDMap = {};
	this.mPerkFilterNameMap = {};
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
};

DynamicPerksOverviewScreen.prototype.createDIV = function(_parentDiv)
{
	console.error(_parentDiv.attr("class"))
	this.mContainer = $("<div class='dpf-overview-screen'/>")
		.appendTo(_parentDiv);
	$('<div class="dpf-overview-title title-font-very-big font-bold font-color-title">Dynamic Perks</div>')
		.appendTo(this.mContainer);

	this.mContentContainer  = $('<div class="dpf-overview-content-container"/>');
	this.mContainer.append(this.mContentContainer)
	this.mContentScrollContainer = $('<div class="dpf-overview-content-scroll-container"/>')
		.appendTo(this.mContentContainer);
	this.mContentContainer.aciScrollBar({
	         delta: 2,
	         lineDelay: 0,
	         lineTimer: 0,
	         pageDelay: 0,
	         pageTimer: 0,
	         bindKeyboard: false,
	         resizable: false,
	         smoothScroll: true
	   });

	var filterContainer = $('<div class="dpf-overview-filter-container"/>')
		.appendTo(this.mContainer);
	this.createFilterBar(filterContainer);

	// var footer = $('<div class="dpf-overview-footer"/>')
	// 	.appendTo(this.mContainer);
    // this.mLeaveButton = footer.createTextButton("Leave", $.proxy(function()
	// {
    //     this.onLeaveButtonPressed();
    // }, this));
};

DynamicPerksOverviewScreen.prototype.createFilterBar = function(_container)
{
	var self = this;
    var row = $('<div class="dpf-overview-filter-bar-label"/>');
    var anem = $('<div class="title-font-normal font-color-subtitle">Filter by name</div>')
    	.appendTo(_container);
    var filterLayout = $('<div class="dpf-overview-filter-bar-container"/>')
        .appendTo(_container);
    var filterInput = $('<input type="text" class="dpf-filter"/>')
        .appendTo(filterLayout)
        .on("keyup", function(_event){
        	console.error("keyup " + $(this).val())
            var currentInput = $(this).val().toLowerCase();
            if (currentInput == "")
            {
            	$(".dpf-l-perk-container").show();
            }
            else
            {
            	$.each(self.mPerkFilterNameMap, function(_name, _arr){
            		if (_name.toLowerCase().search(currentInput) == -1)
            		{
            			$.each(_arr, function(_, _innerPerk){
            				_innerPerk.Container.hide();
            			})
            		}
            		else
            		{
            			$.each(_arr, function(_, _innerPerk){
            				_innerPerk.Container.show();
            			})
            		}
            	})
            }
            $(".dpf-overview-perks-row").each(function(){
            	console.error($(this).height())
            	if ($(this).height() == 0)
            		$(this).hide()
            	else $(this).show()
            })
        })
}

DynamicPerksOverviewScreen.prototype.createContent = function(_data)
{
	var self = this;
	this.mPerkGroupCollectionData = _data;
	$.each(this.mPerkGroupCollectionData, function(_id, _perkGroupCollection)
	{
		var perkGroupCollectionContainer = $('<div class="dpf-overview-perk-group-collection-container"/>')
			.append($("<div class='dpf-overview-perk-group-collection-name title-font-normal font-bold font-color-brother-name'>" + _perkGroupCollection.Name + "</div>"))
			.appendTo(self.mContentScrollContainer);
		$.each(_perkGroupCollection.PerkGroups, function(_perkGroupID, _perkGroupData){
			perkGroupCollectionContainer.append(self.createPerkGroupRow(_perkGroupData));
		})
	})
}

DynamicPerksOverviewScreen.prototype.createPerkGroupRow = function(_perkGroupData)
{
	var self = this;
	var perkGroup = _perkGroupData.perkGroup;
	var perks = _perkGroupData.perks;

	var rowDIV = $('<div class="dpf-overview-perks-row"/>');
	rowDIV.perkGroupCell = $('<div class="dpf-overview-perks-row-cell dpf-overview-perkgroup-cell"/>')
		.appendTo(rowDIV);
	perkGroup.Container = $('<div class="dpf-l-perk-container"/>')
		.appendTo(rowDIV.perkGroupCell);
	var tooltipID = "PerkGroup+" + perkGroup.ID;
	perkGroup.Image = $('<img class="dfp-perk-image-layer"/>')
		.attr('src', Path.GFX + perkGroup.Icon)
		.appendTo(perkGroup.Container)
		.bindTooltip({ contentType: 'msu-generic', modId: DynamicPerks.ID, elementId: tooltipID });
	self.addPerkToFilterMaps(perkGroup);
	rowDIV.cells = [];
	for (var i = 0; i < 7; i++)
	{
		var cell = $('<div class="dpf-overview-perks-row-cell"/>');
		rowDIV.cells.push(cell);
		rowDIV.append(cell);
	}


	$.each(perks, function(_i, _tier){
		$.each(_tier, function(_, _perk)
		{
			_perk.Container = $('<div class="dpf-l-perk-container"/>');
			rowDIV.cells[_i].append(_perk.Container);

			_perk.Image = $('<img class="dpf-perk-image-layer"/>');
			_perk.Image.attr('src', Path.GFX + _perk.Icon);
			_perk.Image.bindTooltip({ contentType: 'ui-perk', entityId: null, perkId: _perk.ID });
			_perk.Container.append(_perk.Image);
			self.addPerkToFilterMaps(_perk);
		})
	})
	return rowDIV;
}

DynamicPerksOverviewScreen.prototype.addPerkToFilterMaps = function(_perk)
{
	console.error(_perk.Name)
	if (_perk.ID in this.mPerkFilterIDMap) this.mPerkFilterIDMap[_perk.ID].push(_perk);
	else this.mPerkFilterIDMap[_perk.ID] = [_perk];

	if (_perk.Name in this.mPerkFilterNameMap) this.mPerkFilterNameMap[_perk.Name].push(_perk);
	else this.mPerkFilterNameMap[_perk.Name] = [_perk];
}


DynamicPerksOverviewScreen.prototype.show = function(_data)
{
	if (this.mIsFirstLoad)
		this.createContent(_data);
	MSUUIScreen.prototype.show.call(this);
}

DynamicPerksOverviewScreen.prototype.showThing = function()
{
	console.error("DynamicPerksOverviewScreen.prototype.showThing")
	SQ.call(this.mSQHandle, 'show');
}

registerScreen("DynamicPerksOverviewScreen", new DynamicPerksOverviewScreen());

var showThing = $("<div class='pullupthing'/>")
	.appendTo($(document.body));
showThing.on("click", function(){
	Screens.DynamicPerksOverviewScreen.showThing();
})
