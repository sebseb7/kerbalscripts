//DEORBIT
//@LAZYGLOBAL OFF.


//todo: activate engines/stage

print "------------------------".
print "-- Deorbit Initialted --".
print "------------------------".

set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 30.

//set deorbit_height to -1000.
//set deorbit_height to 59000.//minimal & safe
set deorbit_height to -1000.//faster, may not work from High ApA

function logev {
	parameter text.

	print "T+"+round(missiontime) +": "+text+" (sAlt:"+round(radar_alt) + ") (sSpd:" + round(ship:velocity:surface:mag,1)+")".
}

function set_partmodule_field {
	parameter part_name.
	parameter module_name.
	parameter field_name.
	parameter field_value.

	for parapart IN SHIP:PARTSDUBBED(part_name)  {
		if parapart:allmodules:contains(module_name) {
			if parapart:allmodules:contains(module_name) {
				parapart:getmodule(module_name):setfield(field_name,field_value).
			}
		}
	}
}

function do_partmodule_event {
	parameter part_name.
	parameter module_name.
	parameter event_name.

	for parapart IN SHIP:PARTSDUBBED(part_name)  {
		if parapart:allmodules:contains(module_name) {
			if parapart:getmodule(module_name):hasevent(event_name) {
				parapart:getmodule(module_name):DOEVENT(event_name).
			}
		}
	}
}

function set_parachute_pressure {
	parameter para_name.
	parameter pressure.

	set_partmodule_field(para_name,"ModuleParachute","min pressure",pressure).
}
function set_parachute_alt {
	parameter para_name.
	parameter alti.
	
	set_partmodule_field(para_name,"ModuleParachute","altitude",alti).
}
function arm_parachute {
	parameter para_name.
	
	do_partmodule_event(para_name,"ModuleParachute","deploy chute").
}
function cut_parachute {
	parameter para_name.
	
	do_partmodule_event(para_name,"ModuleParachute","cut parachute").
}

set_parachute_pressure("PARA_D1",1).
set_parachute_pressure("PARA_D2",1).
set_parachute_pressure("PARA_M1",1).
set_parachute_pressure("PARA_M2",1).
set_parachute_pressure("PARA_M3",1).
set_parachute_pressure("PARA_M4",1).
set_parachute_alt("PARA_D1",100).
set_parachute_alt("PARA_D2",100).
set_parachute_alt("PARA_M1",100).
set_parachute_alt("PARA_M2",100).
set_parachute_alt("PARA_M3",100).
set_parachute_alt("PARA_M4",100).

if not(ship:body:name = "Kerbin") {
	print "wait for kerbin:" + ship:body:name.
	wait until ship:body:name = "Kerbin".
}

SAS OFF.
RCS OFF.
set tset to 0.
lock throttle to tset. 

function do_sm_sep {


	if SHIP:ALTITUDE > 65000 {
		print "- steer OUT".
		RCS ON.
		set side to R(10,10,0). 
		LOCK STEERING TO SHIP:UP + correctRoll + side.
	}
	
	when VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR) < 5 or SHIP:ALTITUDE < 65000 then {
	
		print "- SMjet in 5".
		set lestimestamp to time:seconds.

		when (time:seconds > (lestimestamp+5))or SHIP:ALTITUDE < 65000 then
		{
			print "- SMjet".
			do_partmodule_event("SMJET_DEC","ModuleDecouple","decouple").
			RCS OFF.
		
			if SHIP:ALTITUDE < 65000{
				print "- steer RG (2)".
				LOCK STEERING TO SHIP:SRFRETROGRADE + correctRoll. 
			}else{
				when SHIP:ALTITUDE < 65000 then {
					print "- steer RG (3)".
					LOCK STEERING TO SHIP:SRFRETROGRADE + correctRoll. 
				}
			}
		}
	}
}

function check_for_sm_sep {

	if SHIP:PARTSDUBBED("SMJET_DEC"):LENGTH = 1 {
	
		print "- waitfor sm_sep at 68000".
		when SHIP:ALTITUDE < 68000 then {

			if SHIP:PARTSDUBBED("SMJET_DEC"):LENGTH = 1 {
				do_sm_sep().
			}
		}
	}
		
	if SHIP:PARTSDUBBED("LAS"):LENGTH = 1 {
	
		print "- waitfor las_sep at 63000".
		when SHIP:ALTITUDE < 63000 then {
			run las_jet.
		}
	}
		
	when SHIP:ALTITUDE < 63000 then {
		print "- steer RG (4)".
		LOCK STEERING TO SHIP:SRFRETROGRADE + correctRoll. 
	}	
	
}

function do_deorbit {

	print "- steer RG (for burn)".

	LOCK STEERING TO SHIP:RETROGRADE + correctRoll. 
	
	when VECTORANGLE(SHIP:RETROGRADE:VECTOR,SHIP:FACING:VECTOR) < 5 then {
	
		print "- fire".
		set tset to 1.
		
		when VECTORANGLE(SHIP:RETROGRADE:VECTOR,SHIP:FACING:VECTOR) > 6 or periapsis < deorbit_height then {
			
			print "- stop firing".
			set tset to 0.
			if periapsis > deorbit_height {
				do_deorbit().
			}
		}
		
		when periapsis < deorbit_height then {

			print "- deorbit done".
			check_for_sm_sep().
			unlock steering.
		}
	}
}

if periapsis > deorbit_height {

	do_deorbit().
}
else
{
	print "- deorbit good".
	check_for_sm_sep().
}

WHEN ship:velocity:surface:mag < 1500 then {

	logev("Arm D").
	arm_parachute("PARA_D1").
	arm_parachute("PARA_D2").

	WHEN radar_alt < 5000 then {
		logev("steer unlock").
		unlock steering.
	}

	WHEN radar_alt < 3000 and ship:velocity:surface:mag < 700 then {
		
		logev("Pre D").
		set_parachute_pressure("PARA_D1",0).
		set_parachute_pressure("PARA_D2",0).

		WHEN RADAR_alt < 2000  and ship:velocity:surface:mag < 500 then {
			logev("full d1").
			set_parachute_alt("PARA_D1",5000).
		}
		WHEN RADAR_alt < 1000  and ship:velocity:surface:mag < 500 then {
			logev("full d2").
			set_parachute_alt("PARA_D2",5000).
		}
			
		WHEN ship:velocity:surface:mag < 40 and  RADAR_alt < 1000 then {
			logev("HS Jet").
			do_partmodule_event("HS","ModuleDecouple","jettison heat shield").
		}
	
		WHEN radar_alt < 500 and ship:velocity:surface:mag < 300 then {
			
			logev("Cut D & Arm Main & Pre Main").
			cut_parachute("PARA_D1").
			cut_parachute("PARA_D2").
			arm_parachute("PARA_M1").
			arm_parachute("PARA_M2").
			arm_parachute("PARA_M3").
			arm_parachute("PARA_M4").
			set_parachute_pressure("PARA_M1",0).
			set_parachute_pressure("PARA_M2",0).
			set_parachute_pressure("PARA_M3",0).
			set_parachute_pressure("PARA_M4",0).

			WHEN RADAR_alt < 420  and ship:velocity:surface:mag < 250 then {
				logev("Full 1").
				set_parachute_alt("PARA_M1",5000).
			}
			WHEN RADAR_alt < 200  and ship:velocity:surface:mag < 250 then {
				logev("Full 2").
				set_parachute_alt("PARA_M2",5000).
			}
			WHEN RADAR_alt < 100  and ship:velocity:surface:mag < 250 then {
				logev("Full 3").
				set_parachute_alt("PARA_M3",5000).
			}
			WHEN RADAR_alt < 50 and ship:velocity:surface:mag < 250 then {
				logev("Full 4").
				set_parachute_alt("PARA_M4",5000).
			}
		}
	}
}

when ship:velocity:surface:mag < 1 then {
	logev("Contact").
	print "------------------------".
}

