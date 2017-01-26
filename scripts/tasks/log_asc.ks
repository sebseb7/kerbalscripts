global task_log_asc_state to 0.
global task_log_asc_cb to 0.
function task_log_asc
{
	parameter action is 0.
	parameter value is 0.
	
	if action = 1 {

		set task_log_asc_cb to value.
		return.
	}

	if task_log_asc_state = 0 {
	
		set task_log_asc_state to 1.


		on round(time:seconds,1) {

			if task_log_asc_state = 0 return false.
	
			local angle to VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR).

			log round(missiontime,2)+" "+round(radar_alt,2)+" "+round(angle,2)+" "+round(velocity:surface:mag,2)+" " to "0:/logs/launchlog.txt".

			return true.
		}


	}else{
	
		set task_log_asc_state to 0.
	
	}
	set_task_state(task_log_asc_cb,task_log_asc_state).

}

register_task("Log","asc",1,task_log_asc@).
