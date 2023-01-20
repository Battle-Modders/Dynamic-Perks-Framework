this.DPF_NoPerkGroup <- ::inherit(::DPF.Class.PerkGroup, {
	m = {},
	function create()
	{
		this.perk_group.create();
		this.m.ID = "DPF_NoPerkGroup";
		this.m.Name = "NoPerkGroup";
		this.m.FlavorText = ["No perk group"];
	}
});
