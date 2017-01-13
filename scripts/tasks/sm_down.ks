
function task_sm_down
{
	sas off.
	lock steering to -ship:up.
}

register_task("steer","down",0,task_sm_down@).
