//DEORBIT
//@LAZYGLOBAL OFF.


//todo: activate engines/stage


set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 30.

//set deorbit_height to -1000.
//set deorbit_height to 59000.//minimal
set deorbit_height to -1000.//faster


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
	
	if SHIP:PARTSDUBBED(para_name):LENGTH > 0 {
		if SHIP:PARTSDUBBED(para_name)[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("deploy chute") {
			SHIP:PARTSDUBBED(para_name)[0]:getmodule("ModuleParachute"):DOEVENT("deploy chute").
		}
	}
}
function cut_parachute {
	parameter para_name.
	
	if SHIP:PARTSDUBBED(para_name):LENGTH > 0 {
		if SHIP:PARTSDUBBED(para_name)[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("cut parachute") {
			SHIP:PARTSDUBBED(para_name)[0]:getmodule("ModuleParachute"):DOEVENT("cut parachute").
		}
	}
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

	print "- steer OUT".

	if SHIP:ALTITUDE > 65000 {
		RCS ON.
		set side to R(10,10,0). 
		LOCK STEERING TO SHIP:UP + correctRoll + side.
	}
	
	when VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR) < 5 or SHIP:ALTITUDE < 65000 then {
	
		print "- sep timeout".

		set lestimestamp to time:seconds.

		when (time:seconds > (lestimestamp+5))or SHIP:ALTITUDE < 65000 then
		{
			print "- timeout done".

			if SHIP:PARTSDUBBED("SMJET_DEC"):LENGTH = 1 {
				print ".1".
				if SHIP:PARTSDUBBED("SMJET_DEC")[0]:allmodules:contains("ModuleDecouple") {
					print ".2".
					if SHIP:PARTSDUBBED("SMJET_DEC")[0]:getmodule("ModuleDecouple"):hasevent("decouple") {
						print ".3".
						SHIP:PARTSDUBBED("SMJET_DEC")[0]:getmodule("ModuleDecouple"):DOEVENT("decouple").
						RCS OFF.
					}
				}
			}
		
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

lock t_h to SHIP:GEOPOSITION:TERRAINHEIGHT.
lock radar_alt to SHIP:ALTITUDE-( (t_h + sqrt(t_h*t_h)) / 2 ). 

WHEN ship:velocity:surface:mag < 1500 then {

	print round(missiontime) +" arm chutes "+round(ship:ALTITUDE).
	arm_parachute("PARA_D1").
	arm_parachute("PARA_D2").

	WHEN radar_alt < 5050 then {
		print round(missiontime) +" unlock steer "+round(radar_alt).
		unlock steering.
	}

	WHEN radar_alt < 5000 and ship:velocity:surface:mag < 700 then {
		
		print round(missiontime) +" pre D "+round(radar_alt).
		set_parachute_pressure("PARA_D1",0).
		set_parachute_pressure("PARA_D2",0).
			print ship:mass.

		WHEN RADAR_alt < 3000  and ship:velocity:surface:mag < 500 then {
			print round(missiontime) +" full D1 "+round(radar_alt).
			set_parachute_alt("PARA_D1",5000).
		}
		WHEN RADAR_alt < 1000  and ship:velocity:surface:mag < 500 then {
			print round(missiontime) +" full D2 "+round(radar_alt).
			print ship:mass.
			set_parachute_alt("PARA_D2",5000).
		}
			
		WHEN ship:velocity:surface:mag < 40 and  RADAR_alt < 1000 then {
			print round(missiontime) +" HS "+round(radar_alt).
			print ship:mass.
			if SHIP:PARTSDUBBED("HS"):LENGTH = 1 {
				SHIP:PARTSDUBBED("HS")[0]:getmodule("ModuleDecouple"):DOEVENT("jettison heat shield").
			}
		}
	
		WHEN radar_alt < 500 and ship:velocity:surface:mag < 300 then {
			
			print ship:mass.
			print round(missiontime) +" pre M "+round(radar_alt).
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
			print ship:mass.
				print round(missiontime) +" full 1 "+round(radar_alt).
				set_parachute_alt("PARA_M1",5000).
			}
			WHEN RADAR_alt < 200  and ship:velocity:surface:mag < 250 then {
				print round(missiontime) +" full 2 "+round(radar_alt).
				set_parachute_alt("PARA_M2",5000).
			}
			WHEN RADAR_alt < 100  and ship:velocity:surface:mag < 250 then {
				print round(missiontime) +" full 3 "+round(radar_alt).
				set_parachute_alt("PARA_M3",5000).
			}
			WHEN RADAR_alt < 50 and ship:velocity:surface:mag < 250 then {
			print ship:mass.
				print round(missiontime) +" full 4 "+round(radar_alt).
				set_parachute_alt("PARA_M4",5000).
			}
		}
	}
}

when ship:ALTITUDE < 10000 then {
	when radar_alt < 10 then {
		print "sequence end".
	}
}

