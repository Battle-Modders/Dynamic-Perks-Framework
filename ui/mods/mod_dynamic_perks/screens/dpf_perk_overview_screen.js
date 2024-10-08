var DynamicPerksOverviewScreen = function ()
{
	MSUUIScreen.call(this);
	this.mPerkGroupCollectionData = null;
	this.mContentContainer = null;
	this.mContentScrollContainer = null;
	this.mNameFilterInput = null;

	this.mLeaveButton = null;
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
    var filterRow = $('<div class="dpf-overview-filter-by-name-row"/>')
    	.appendTo(_container);
    var name = $('<span class="title-font-normal font-color-subtitle">Filter by name</span>')
    	.appendTo(filterRow);
    var filterLayout = $('<div class="dpf-overview-filter-bar-container"/>')
        .appendTo(filterRow);
    this.mNameFilterInput = $('<input type="text" class="dpf-filter title-font-big font-bold font-color-brother-name"/>')
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
                    self.mContentScrollContainer.find(".dpf-l-perk-container").show();
                    self.mContentScrollContainer.find(".dpf-overview-perks-row").show();
                }
                else
                {
                    self.mContentScrollContainer.find('.dpf-l-perk-container[data-perktype="perk"]').each(function(){
                        if ($(this).attr("data-perkname").toLowerCase().search(currentInput) == -1)
                        {
                            $(this).hide();
                        }
                        else
                        {
                            $(this).show();
                            $(this).parent().parent().show(); // show perk row otherwise it won't reset
                        }
                    })
                    self.mContentScrollContainer.find(".dpf-overview-perks-row").each(function(){
                        var visibleChildren = $(this).find('.dpf-l-perk-container[data-perktype="perk"]:visible');
                        if (visibleChildren.length == 0)
                            $(this).hide()
                        else $(this).show()
                    })
                }
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
	$.each(_perkGroupCollection.PerkGroups, function(_perkGroupID, _perkGroupData)
	{
		perkGroupCollectionContainer.append(self.createPerkGroupRow(_perkGroupData));
	})
	return perkGroupCollectionContainer;
}

DynamicPerksOverviewScreen.prototype.createPerkGroupRow = function(_perkGroupData)
{
	var self = this;
	var perkGroup = _perkGroupData.perkGroup;
	var perks = _perkGroupData.perks;

	var rowDIV = $('<div class="dpf-overview-perks-row"/>')
		.attr("data-perkgroupid", perkGroup.ID);

	var perkGroupCell = $('<div class="dpf-overview-perks-row-cell dpf-overview-perkgroup-cell"/>')
		.appendTo(rowDIV);


	perkGroup.Container = this.createPerkContainer(perkGroup)
		.attr("data-perktype", "perkgroup")
		.appendTo(perkGroupCell);

	var tooltipID = "PerkGroup+" + perkGroup.ID;
	perkGroup.Image = this.createPerkImage(perkGroup)
		.appendTo(perkGroup.Container)
		.bindTooltip({ contentType: 'msu-generic', modId: DynamicPerks.ID, elementId: tooltipID });

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
			_perk.Container = self.createPerkContainer(_perk)
				.attr("data-perktype", "perk")
				.appendTo(rowDIV.cells[_i]);

			_perk.Image = self.createPerkImage(_perk)
				.appendTo(_perk.Container)
				.bindTooltip({ contentType: 'ui-perk', entityId: null, perkId: _perk.ID });
		})
	})
	return rowDIV;
}

DynamicPerksOverviewScreen.prototype.createPerkContainer = function(_perkData)
{
	var container = $('<div class="dpf-l-perk-container"/>')
		.attr("data-perkid", _perkData.ID)
		.attr("data-perkname", _perkData.Name);
	return container;
}

DynamicPerksOverviewScreen.prototype.createPerkImage = function(_perkData)
{
	var image = $('<img class="dpf-perk-image-layer"/>');
	image.attr('src', Path.GFX + _perkData.Icon);
	return image;
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
