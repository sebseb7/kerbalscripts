
global task_kerbin_launch_state to 0.
global task_kerbin_launch_cb to 0.

function task_kerbin_launch
{
	parameter action is 0.
	parameter value is 0.
	
	if action = 1 {

		set task_kerbin_launch_cb to value.
		return.
	}

	if task_kerbin_launch_state = 0 {
	
		if prog_mode=0 {
			set task_kerbin_launch_state to 1.
			set prog_mode to 1.
			when not(prog_mode=1) then {
				set task_kerbin_launch_state to 0.
				set_task_state(task_kerbin_launch_cb,task_kerbin_launch_state).
			}
			run launch.
		}

	}else{
	
		if prog_mode=1 {
			set prog_mode to 0.
		}

		set task_kerbin_launch_state to 0.
	
	}
	
	set_task_state(task_kerbin_launch_cb,task_kerbin_launch_state).

}


register_task("L&L","Kerbin Launch",1,task_kerbin_launch@).
