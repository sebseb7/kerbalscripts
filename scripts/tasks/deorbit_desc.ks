
global task_deorbit_desc_state to 0.
global task_deorbit_desc_cb to 0.

function task_deorbit_desc
{
	parameter action is 0.
	parameter value is 0.
	
	if action = 1 {

		set task_deorbit_desc_cb to value.
		return.
	}

	if task_deorbit_desc_state = 0 {
	
		if prog_mode=0 {
			set task_deorbit_desc_state to 1.
			set prog_mode to 2.
			when not(prog_mode=2) then {
				set task_deorbit_desc_state to 0.
				set_task_state(task_deorbit_desc_cb,task_deorbit_desc_state).
			}
			run desc.
		}

	}else{
	
		if prog_mode=2 {
			set prog_mode to 0.
		}

		set task_deorbit_desc_state to 0.
	
	}
	
	set_task_state(task_deorbit_desc_cb,task_deorbit_desc_state).

}


register_task("L&L","Deorbit Kerbin (powered)",1,task_deorbit_desc@).
