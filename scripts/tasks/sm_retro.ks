
function task_sm_retro
{
	sas off.
	lock steering to retrograde.
}

register_task("steer","retrograde",0,task_sm_retro@).
