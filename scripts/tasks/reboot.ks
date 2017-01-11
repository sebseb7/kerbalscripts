
function task_reboot
{
	gui:hide().
	reboot.

}

register_task("misc","Reboot",0,task_reboot@).
