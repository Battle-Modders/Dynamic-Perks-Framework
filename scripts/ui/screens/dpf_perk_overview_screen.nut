this.dpf_perk_overview_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "DynamicPerksOverviewScreen",
	}

	function create() 
	{

	}

	function getUIData()
	{
		local ret = {};
		foreach (idx, category in ::DynamicPerks.PerkGroupCategories.getOrdered())
		{
			ret[category.getID()] <- {
				ID = category.getID(),
				Name = category.getName(),
				PerkGroups = {}
			};
			foreach (perkGroupID in category.getGroups())
			{
				local perkCollectionEntry = ret[category.getID()].PerkGroups;
				local perkGroup = ::DynamicPerks.PerkGroups.findById(perkGroupID);
				local perkTree = ::new(::DynamicPerks.Class.PerkTree);
				perkTree.addPerkGroup(perkGroupID);
				perkCollectionEntry[perkGroupID] <- {
					perkGroup = perkGroup.toUIData(),
					perks = perkTree.toUIData(),
				}
			}
		}
		ret["special"] <- {
			ID = "special",
			Name = "Special",
			PerkGroups = {}
		};
		foreach (perkGroup in ::DynamicPerks.PerkGroups.getByType(::DynamicPerks.Class.SpecialPerkGroup))
		{
			local perkCollectionEntry = ret["special"].PerkGroups;
			local perkTree = ::new(::DynamicPerks.Class.PerkTree);
			perkTree.addPerkGroup(perkGroup.m.ID);
			perkCollectionEntry[perkGroup.m.ID] <- {
				perkGroup = perkGroup.toUIData(),
				perks = perkTree.toUIData(),
			}

		}
		::MSU.Log.printData(ret["special"], 3, true, 3)
		return ret;
	}

	function show()
	{
		this.ui_screen.show(this.getUIData());
	}
})
