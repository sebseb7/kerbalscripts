
function task_sm_up
{
	sas off.
	lock steering to up.
}

register_task("steer","up",0,task_sm_up@).
