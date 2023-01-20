this.DPF_RandomPerkGroup <- ::inherit(::DPF.Class.PerkGroup, {
	m = {},
	function create()
	{
		this.perk_group.create();
		this.m.ID = "DPF_RandomPerkGroup";
		this.m.Name = "Random";
		this.m.FlavorText = ["Random perk group"];
	}
});
