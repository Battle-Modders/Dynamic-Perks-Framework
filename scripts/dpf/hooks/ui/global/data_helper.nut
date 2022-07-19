::mods_hookNewObject("ui/global/data_helper", function (o) {
	local convertEntityToUIData = o.convertEntityToUIData;
	o.convertEntityToUIData = function( _entity, _activeEntity )
	{
		// local result = convertEntityToUIData(_entity, _activeEntity);
		// if (_entity.getBackground() != null)
		// {
		// 	result.perkTree <- _entity.getBackground().getPerkTree().getTree();
		// }
		// return result;

		local result = {
			id = _entity.getID(),
			flags = {},
			character = {},
			stats = {},
			activeSkills = {},
			passiveSkills = {},
			statusEffects = {},
			injuries = [],
			perks = [],
			perkTree = [],
			equipment = {},
			bag = [],
			ground = []
		};
		this.addFlagsToUIData(_entity, _activeEntity, result.flags);
		this.addCharacterToUIData(_entity, result.character);
		local bg = _entity.getBackground();
		if (bg != null)
		{
			result.perkTree = _entity.getBackground().getPerkTree().getTree();
		}
		this.addStatsToUIData(_entity, result.stats);
		local skills = _entity.getSkills();
		this.addSkillsToUIData(skills.querySortedByItems(this.Const.SkillType.Active), result.activeSkills);
		this.addSkillsToUIData(skills.querySortedByItems(this.Const.SkillType.Trait | this.Const.SkillType.PermanentInjury), result.passiveSkills);
		local injuries = skills.query(this.Const.SkillType.TemporaryInjury | this.Const.SkillType.SemiInjury);

		foreach( i in injuries )
		{
			result.injuries.push({
				id = i.getID(),
				imagePath = i.getIconColored()
			});
		}

		this.addSkillsToUIData(skills.querySortedByItems(this.Const.SkillType.StatusEffect, this.Const.SkillType.Trait), result.passiveSkills);
		this.addPerksToUIData(_entity, skills.query(this.Const.SkillType.Perk, true), result.perks);
		local items = _entity.getItems();
		this.convertPaperdollEquipmentToUIData(items, result.equipment);
		this.convertBagItemsToUIData(items, result.bag);

		if (this.Tactical.isActive() && _entity.getTile() != null)
		{
			this.convertItemsToUIData(_entity.getTile().Items, result.ground);
			result.ground.push(null);
		}

		return result;
	}

	o.convertPerksToUIData = function()
	{
		return ::Const.Perks.DefaultPerkTree.getTree();
	}

	o.convertPerkToUIData = function( _perkID, _background )
	{
		local perk = _background.getPerkTree().getPerk(_perkID);

		if (perk != null)
		{
			return {
				id = perk.ID,
				name = perk.Name,
				description = perk.Tooltip,
				imagePath = perk.Icon
			};
		}

		return null;
	}
});
