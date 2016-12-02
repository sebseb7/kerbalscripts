//DEORBIT
//@LAZYGLOBAL OFF.


//todo: activate engines/stage


set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 30.

//set deorbit_height to -1000.
set deorbit_height to 59000.
set correctRoll to R(0,0,-180). 


function set_parachute_pressure {
	parameter para_name.
	parameter pressure.
			
	if SHIP:PARTSDUBBED(para_name):LENGTH > 0 {

		if SHIP:PARTSDUBBED(para_name)[0]:allmodules:contains("ModuleParachute") {

			SHIP:PARTSDUBBED(para_name)[0]:getmodule("ModuleParachute"):setfield("min pressure",pressure).

		}
	}
}
function set_parachute_alt {
	parameter para_name.
	parameter alti.
			
	if SHIP:PARTSDUBBED(para_name):LENGTH > 0 {

		if SHIP:PARTSDUBBED(para_name)[0]:allmodules:contains("ModuleParachute") {

			SHIP:PARTSDUBBED(para_name)[0]:getmodule("ModuleParachute"):setfield("altitude",alti).

		}
	}
}
function arm_parachute {
	parameter para_name.
	
	if SHIP:PARTSDUBBED(para_name)[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("deploy chute") {
		SHIP:PARTSDUBBED(para_name)[0]:getmodule("ModuleParachute"):DOEVENT("deploy chute").
	}
}

set_parachute_pressure("PARA_M1",1).
set_parachute_pressure("PARA_M2",1).
set_parachute_pressure("PARA_M3",1).
set_parachute_pressure("PARA_M4",1).
set_parachute_alt("PARA_M1",100).
set_parachute_alt("PARA_M2",100).
set_parachute_alt("PARA_M3",100).
set_parachute_alt("PARA_M4",100).

if not(ship:body:name = "Kerbin") {
	print "wait for kerbin:" + ship:body:name.
	wait until ship:body:name = "Kerbin".
}

SAS OFF.
set tset to 0.
lock throttle to tset. 

function do_sm_sep {

	print "- steer OUT".

	if SHIP:ALTITUDE > 65000 {
		LOCK STEERING TO SHIP:UP + correctRoll.
	}
	
	when VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR) < 5 or SHIP:ALTITUDE < 65000 then {
	
		print "- sep timeout".

		set lestimestamp to time:seconds.

		when time:seconds > (lestimestamp+10) then
		{
			print "- timeout done".

			if SHIP:PARTSDUBBED("SMJET_DEC"):LENGTH = 1 {
				print ".1".
				if SHIP:PARTSDUBBED("SMJET_DEC")[0]:allmodules:contains("ModuleDecouple") {
					print ".2".
					if SHIP:PARTSDUBBED("SMJET_DEC")[0]:getmodule("ModuleDecouple"):hasevent("decouple") {
						print ".3".
						SHIP:PARTSDUBBED("SMJET_DEC")[0]:getmodule("ModuleDecouple"):DOEVENT("decouple").
					}
				}
			}
		
			if SHIP:ALTITUDE < 65000{
				print "- steer RG (2)".
				LOCK STEERING TO SHIP:RETROGRADE + correctRoll. 
			}else{
				when SHIP:ALTITUDE < 65000 then {
					print "- steer RG (3)".
					LOCK STEERING TO SHIP:RETROGRADE + correctRoll. 
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
		LOCK STEERING TO SHIP:RETROGRADE + correctRoll. 
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

	print round(missiontime) +" arm chutes "+round(alt:radar).
	arm_parachute("PARA_M1").
	arm_parachute("PARA_M2").
	arm_parachute("PARA_M3").
	arm_parachute("PARA_M4").

	WHEN alt:radar < 10000 then {
		print round(missiontime) +" unlock steer "+round(alt:radar).
		unlock steering.
	}
	WHEN alt:radar < 5000 then {
		
		WHEN ALT:RADAR < 6000  and ship:velocity:surface:mag < 300 then {
			print round(missiontime) +" pre 1 "+round(alt:radar).
			set_parachute_pressure("PARA_M1",0).
		}

		WHEN ALT:RADAR < 3000  and ship:velocity:surface:mag < 300 then {
			print round(missiontime) +" pre 2 "+round(alt:radar).
			set_parachute_pressure("PARA_M2",0).
		}
		WHEN ALT:RADAR < 2500  and ship:velocity:surface:mag < 300 then {
			print round(missiontime) +" pre 3 "+round(alt:radar).
			set_parachute_pressure("PARA_M3",0).
		}
		WHEN ALT:RADAR < 2000  and ship:velocity:surface:mag < 200 then {
			print round(missiontime) +" pre 4 "+round(alt:radar).
			set_parachute_pressure("PARA_M4",0).
		}

		WHEN ALT:RADAR < 1000  and ship:velocity:surface:mag < 200 then {
			print round(missiontime) +" full 1 "+round(alt:radar).
			set_parachute_alt("PARA_M1",5000).
		}
		WHEN ALT:RADAR < 300  and ship:velocity:surface:mag < 200 then {
			print round(missiontime) +" full 2 "+round(alt:radar).
			set_parachute_alt("PARA_M2",5000).
		}
		WHEN ALT:RADAR < 200  and ship:velocity:surface:mag < 200 then {
			print round(missiontime) +" full 3 "+round(alt:radar).
			set_parachute_alt("PARA_M3",5000).
		}
		WHEN ALT:RADAR < 100 and ship:velocity:surface:mag < 200 then {
			print round(missiontime) +" full 4 "+round(alt:radar).
			set_parachute_alt("PARA_M4",5000).
		}
		WHEN ship:velocity:surface:mag < 12 and  ALT:RADAR < 140 then {
			print round(missiontime) +" HS "+round(alt:radar).
			if SHIP:PARTSDUBBED("HS"):LENGTH = 1 {
				SHIP:PARTSDUBBED("HS")[0]:getmodule("ModuleDecouple"):DOEVENT("jettison heat shield").
			}
		}
	}
}

when alt:radar < 10 then {.
	print "sequence end".
}

