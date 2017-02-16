
function task_misc_payload
{
	sas off.
	rcs off.
	global steering_target to facing.
	lock steering to steering_target.

	do_partmodule_event("DOOR_1","ModuleAnimateGeneric","open doors").
	do_partmodule_event("DOOR_2","ModuleAnimateGeneric","open doors").
	do_partmodule_event("DOOR_3","ModuleAnimateGeneric","open doors").
	do_partmodule_event("DOOR_4","ModuleAnimateGeneric","open doors").
	
	//wait 10
	global seconds_g to sessiontime+30.
	when seconds_g < sessiontime then {

		do_partmodule_event("PAYLOAD_DEC","ModuleDockingNode","decouple node").
		do_partmodule_event("PAYLOAD_DEC","ModuleAnimatedDecoupler","decouple").
		do_partmodule_event("PAYLOAD_DEC","ModuleDecouple","decouple").

		//wait 4
		set seconds_g to sessiontime+4.
		when seconds_g < sessiontime then {
			
			SET SHIP:CONTROL:TOP TO -1.
			rcs on.

			//wait 3
			set seconds_g to sessiontime+3.
			when seconds_g < sessiontime then {
		
				SET SHIP:CONTROL:NEUTRALIZE to True.
				rcs off.
			
				//wait 10
				set seconds_g to sessiontime+10.
				when seconds_g < sessiontime then {

					SET SHIP:CONTROL:TOP TO 1.
					rcs on.
					do_partmodule_event("DOOR_1","ModuleAnimateGeneric","close doors").
					do_partmodule_event("DOOR_2","ModuleAnimateGeneric","close doors").
					do_partmodule_event("DOOR_3","ModuleAnimateGeneric","close doors").
					do_partmodule_event("DOOR_4","ModuleAnimateGeneric","close doors").
			
					//wait 3
					set seconds_g to sessiontime+3.
					when seconds_g < sessiontime then {
		
						SET SHIP:CONTROL:NEUTRALIZE to True.
						rcs off.
						unlock steering.
						sas on.
					}
				}
			}
		}
	}
}

register_task("misc","Release Payload",0,task_misc_payload@).
