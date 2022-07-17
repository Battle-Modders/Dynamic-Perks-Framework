this.perk_group_category <- ::inherit("scripts/dpf/perk_group_collection", {
	m = {
		OrderOfAssignment = 10,
		Min = 1,
		TooltipPrefix = ""
	},
	function create()
	{
		this.perk_group_collection.create();
	}

	function getMin()
	{
		return this.m.Min;
	}

	function setMin( _min )
	{
		::MSU.requireInt(_min);
		this.m.Min = _min;
	}

	function getTooltipPrefix()
	{
		return this.m.TooltipPrefix;
	}

	function setTooltipPrefix( _text )
	{
		::MSU.requireString(_text);
		this.m.TooltipPrefix = _text;
	}

	function getOrderOfAssignment()
	{
		return this.m.OrderOfAssignment;
	}

	function setOrderOfAssignment( _order )
	{
		::MSU.requireInt(_order);
		this.m.OrderOfAssignment = _order;
	}
});
