
global task_deploy_solar_state to 0.
global task_deploy_solar_cb to 0.
function task_deploy_solar
{
	parameter action is 0.
	parameter value is 0.
	
	if action = 1 {

		set task_deploy_solar_cb to value.
		return.
	}

	if task_deploy_solar_state = 0 {
	
		set task_deploy_solar_state to 1.
	
	}else{
	
		set task_deploy_solar_state to 0.
	
	}
	set_task_state(task_deploy_solar_cb,task_deploy_solar_state).

}



register_task("Misc","Deploy Solar",1,task_deploy_solar@).
