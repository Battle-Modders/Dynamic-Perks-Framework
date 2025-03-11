this.dpf_perk_overview_screen <- ::inherit("scripts/mods/msu/ui_screen", {
	m = {
		ID = "DynamicPerksOverviewScreen",
		IsFirstLoad = true,
	},
	function create()
	{
	}

	function getUIData()
	{

		local ret = [];
		local categories = ::DynamicPerks.PerkGroupCategories.getOrdered();
		foreach (idx, category in categories)
		{
			local catObj = {
				ID = category.getID(),
				Name = category.getName(),
				PerkGroups = {}
			};
			ret.push(catObj);
			foreach (perkGroupID in category.getGroups())
			{
				local perkCollectionEntry = catObj.PerkGroups;
				local perkGroup = ::DynamicPerks.PerkGroups.findById(perkGroupID);
				local perkTree = ::new(::DynamicPerks.Class.PerkTree);
				perkTree.addPerkGroup(perkGroupID);
				perkCollectionEntry[perkGroupID] <- {
					perkGroup = perkGroup.toUIData(),
					perks = perkTree.toUIData(),
				}
			}
		}
		local specialGroupCollection = {
			ID = "special",
			Name = "Special",
			PerkGroups = {}
		};
		ret.push(specialGroupCollection);
		foreach (perkGroup in ::DynamicPerks.PerkGroups.getByType(::DynamicPerks.Class.SpecialPerkGroup))
		{
			local perkCollectionEntry = specialGroupCollection.PerkGroups;
			local perkTree = ::new(::DynamicPerks.Class.PerkTree);
			perkTree.addPerkGroup(perkGroup.m.ID);
			perkCollectionEntry[perkGroup.m.ID] <- {
				perkGroup = perkGroup.toUIData(),
				perks = perkTree.toUIData(),
			}
		}
		local loosePerksCollection = {
			ID = "loose_perks_collection",
			Name = "Loose Perks",
			PerkGroups = {
				loose_perks_group = {
					perkGroup = {
						ID = "looseperksgroup",
						Name = "Loose Perks",
						Description = "Loose Perks",
						Icon = ""
					},
					perks = [[]],
				},
			}
		};
		ret.push(loosePerksCollection);
		local looseGroupPerks = loosePerksCollection.PerkGroups["loose_perks_group"].perks[0];
		// lol
		local usedIDs = {};
		foreach(category in ret)
		{
			foreach (perkgroup in category.PerkGroups)
			{
				foreach (row in perkgroup.perks)
				{
					foreach (perk in row)
					{
						usedIDs[perk.ID] <- null;
					}
				}
			}
		}
		foreach (id, perk in ::Const.Perks.LookupMap)
		{
			if (!(id in usedIDs))
			{
				looseGroupPerks.append(perk);
			}
		}
		return ret;
	}

	function show()
	{
		if (this.m.IsFirstLoad) {
			this.ui_screen.show(this.getUIData());
			this.m.IsFirstLoad = false;
		}
		else {
			this.ui_screen.show(null);
		}
	}
})
