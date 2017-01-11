
function task_sm_free
{
	unlock steering.
	sas on.
}

register_task("steer","free",0,task_sm_free@).
