
function task_sm_pro
{
	sas off.
	lock steering to prograde.
}

register_task("steer","prograde",0,task_sm_pro@).
