foreach (file in ::IO.enumerateFiles("dynamic_perks/hooks"))
{
	::include(file);
}
::include("dynamic_perks/config.nut");
::include("dynamic_perks/dynamic_perks_tooltips.nut");
