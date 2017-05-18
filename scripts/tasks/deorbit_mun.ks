
function task_deorbit_mun
{
	gui:hide().
	run once munland.
	open_land_window().
}



register_task("L&L","Deorbit Mun",0,task_deorbit_mun@).
