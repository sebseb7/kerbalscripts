
function task_profile
{
	if homeconnection:isconnected {
		log PROFILERESULT() to "0:/logs/profile".
	}
}

register_task("misc","Profile",0,task_profile@).
