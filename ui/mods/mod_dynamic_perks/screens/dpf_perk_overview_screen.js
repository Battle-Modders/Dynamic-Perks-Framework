var DynamicPerksOverviewScreen = function ()
{
	MSUUIScreen.call(this);
	this.mPerkGroupCollectionData = null;
	this.mContentContainer = null;
	this.mContentScrollContainer = null;
	this.mNameFilterInput = null;

	this.mLeaveButton = null;


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
	this.mContainer = $("<div class='dpf-overview-screen'/>")
		.appendTo(_parentDiv)
		.hide();
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

	var footer = $('<div class="dpf-overview-footer"/>')
		.appendTo(this.mContainer);
    this.mLeaveButton = footer.createTextButton("Leave", $.proxy(function()
	{
        this.onLeaveButtonPressed();
    }, this), null, 1);
};

DynamicPerksOverviewScreen.prototype.createFilterBar = function(_container)
{
	var self = this;
    var row = $('<div class="dpf-overview-filter-bar-label"/>');
    var anem = $('<div class="title-font-normal font-color-subtitle">Filter by name</div>')
    	.appendTo(_container);
    var filterLayout = $('<div class="dpf-overview-filter-bar-container"/>')
        .appendTo(_container);
    this.mNameFilterInput = $('<input type="text" class="dpf-filter"/>')
        .appendTo(filterLayout)
        .on("keyup", function(_event){
        	var currentInput = $(this).val().toLowerCase();
        	// remove extra characters that sneak in
        	currentInput = currentInput.replace(/[\u0127]/g, '');
        	currentInput = currentInput.replace(/\u0127/g, '');
        	currentInput = currentInput.replace("", '');
        	currentInput = currentInput.replace(//g, '');
        	$(this).val(currentInput);

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
	$.each(this.mPerkGroupCollectionData, function(_, _perkGroupCollection)
	{
		var collectionDiv = self.createPerkGroupCollection(_perkGroupCollection);
		self.mContentScrollContainer.append(collectionDiv)
	})
}

DynamicPerksOverviewScreen.prototype.createPerkGroupCollection = function(_perkGroupCollection)
{
	var self = this;
	var perkGroupCollectionContainer = $('<div class="dpf-overview-perk-group-collection-container"/>')
		.append($("<div class='dpf-overview-perk-group-collection-name title-font-normal font-bold font-color-brother-name'>" + _perkGroupCollection.Name + "</div>"))
		.appendTo(self.mContentScrollContainer);
	$.each(_perkGroupCollection.PerkGroups, function(_perkGroupID, _perkGroupData){

		perkGroupCollectionContainer.append(self.createPerkGroupRow(_perkGroupData));
	})
}

DynamicPerksOverviewScreen.prototype.createPerkGroupRow = function(_perkGroupData)
{
	var self = this;
	var perkGroup = _perkGroupData.perkGroup;
	var perks = _perkGroupData.perks;

	var rowDIV = $('<div class="dpf-overview-perks-row"/>');
	rowDIV.attr("data-perkgroupid", perkGroup.ID);
	var perkGroupCell = $('<div class="dpf-overview-perks-row-cell dpf-overview-perkgroup-cell"/>')
		.appendTo(rowDIV);
	perkGroup.Container = $('<div class="dpf-l-perk-container"/>')
		.appendTo(perkGroupCell);
	var tooltipID = "PerkGroup+" + perkGroup.ID;
	perkGroup.Image = $('<img class="dfp-perk-image-layer"/>')
		.attr('src', Path.GFX + perkGroup.Icon)
		.appendTo(perkGroup.Container)
		.bindTooltip({ contentType: 'msu-generic', modId: DynamicPerks.ID, elementId: tooltipID });
	self.addPerkToFilterMaps(perkGroup);
	rowDIV.cells = [];
	for (var i = 0; i < 7; i++)
	{
		var cell = $('<div class="dpf-overview-perks-row-cell perk-cell"/>');
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
	if (_perk.ID in this.mPerkFilterIDMap) this.mPerkFilterIDMap[_perk.ID].push(_perk);
	else this.mPerkFilterIDMap[_perk.ID] = [_perk];

	if (_perk.Name in this.mPerkFilterNameMap) this.mPerkFilterNameMap[_perk.Name].push(_perk);
	else this.mPerkFilterNameMap[_perk.Name] = [_perk];
}

DynamicPerksOverviewScreen.prototype.onLeaveButtonPressed = function()
{
	this.hide();
}

DynamicPerksOverviewScreen.prototype.show = function(_data)
{
	if (_data != null)
		this.createContent(_data);
	var self = this;
	var moveTo = { opacity: 1};
	var offset = -this.mContainer.width();
	this.mContainer.velocity("finish", true).velocity(moveTo,
	{
		duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function ()
		{
			$(this).show();
			$(this).css("opacity", 0);
			self.notifyBackendOnAnimating();
		},
		complete: function ()
		{
			self.mIsVisible = true;
			self.mNameFilterInput.focus();
			self.notifyBackendOnShown();
		}
	});
	this.onShow();
}


DynamicPerksOverviewScreen.prototype.hide = function ()
{
	var self = this;
	var moveTo = { opacity: 0};
	var offset = -this.mContainer.width();
	this.mContainer.velocity("finish", true).velocity(moveTo,
	{
		duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function()
		{
			self.notifyBackendOnAnimating();
		},
		complete: function()
		{
			$(this).hide();
			self.notifyBackendOnHidden();
		}
	});
	this.onHide();
};


MSUUIScreen.prototype.destroyDIV = function ()
{
	this.mContainer.empty();
	this.mContainer.remove();
	this.mContainer = null;
	this.mPerkFilterIDMap = {};
	this.mPerkFilterNameMap = {};
};

DynamicPerksOverviewScreen.prototype.notifyBackendToShow = function()
{
	SQ.call(this.mSQHandle, 'show');
}


registerScreen("DynamicPerksOverviewScreen", new DynamicPerksOverviewScreen());
