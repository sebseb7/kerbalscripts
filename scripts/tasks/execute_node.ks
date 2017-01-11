global task_execute_node_state to 0.
global task_execute_node_cb to 0.

function task_execute_node
{
	parameter action is 0.
	parameter value is 0.
	
	if action = 1 {

		set task_execute_node_cb to value.
		return.
	}

	if task_execute_node_state = 0 {
	
		if prog_mode=0 {
			set task_execute_node_state to 1.
			set prog_mode to 4.
			when not(prog_mode=4) then {
				set task_execute_node_state to 0.
				set_task_state(task_execute_node_cb,task_execute_node_state).
			}
			run exenode.
		}

	}else{
	
		if prog_mode=4 {
			set prog_mode to 0.
		}

		set task_execute_node_state to 0.
	
	}
	
	set_task_state(task_execute_node_cb,task_execute_node_state).

}


register_task("Misc","Execute Node",1,task_execute_node@).
