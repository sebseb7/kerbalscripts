
function task_sm_facing
{
	sas off.
	lock steering to ship:facing.
}

register_task("steer","facing",0,task_sm_facing@).
