
global task_deorbit_state to 0.
global task_deorbit_cb to 0.

function task_deorbit
{
	parameter action is 0.
	parameter value is 0.
	
	if action = 1 {

		set task_deorbit_cb to value.
		return.
	}

	if task_deorbit_state = 0 {
	
		if prog_mode=0 {
			set task_deorbit_state to 1.
			set prog_mode to 10.
			when not(prog_mode=10) then {
				set task_deorbit_state to 0.
				set_task_state(task_deorbit_cb,task_deorbit_state).
			}
			run deorbit.
		}

	}else{
	
		if prog_mode=10 {
			set prog_mode to 0.
		}

		set task_deorbit_state to 0.
	
	}
	
	set_task_state(task_deorbit_cb,task_deorbit_state).

}


register_task("L&L","Deorbit Kerbin",1,task_deorbit@).
