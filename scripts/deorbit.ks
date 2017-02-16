//DEORBIT
//@LAZYGLOBAL OFF.

// 1* Mk12-R sa7 @68% PARA_D1
// 1* Mk12-R sa7 @124% PARA_D2
// 4* symetric Mk2-R sa7 @55% PARA_M*
// Heatshild "HS"
// SM Decoupler : "SMJET_DEC"


//todo: activate engines/stage

clearscreen.

print "------------------------".
print "-- Deorbit Initialted --".
print "------------------------".

//set STEERINGMANAGER:ROLLCONTROLANGLERANGE to 1i0.

set deorbitstarttime to missiontime.

//set deorbit_height to -1000.
//set deorbit_height to 59000.//minimal & safe
set deorbit_height to 30000.//faster
//set deorbit_height to -1000.//faster, may not work from High ApA


function set_partmodule_field {
	parameter part_name.
	parameter module_name.
	parameter field_name.
	parameter field_value.

	for parapart IN SHIP:PARTSDUBBED(part_name)  {
		if parapart:allmodules:contains(module_name) {
			if parapart:getmodule(module_name):allfieldnames:contains(field_name) {
				parapart:getmodule(module_name):setfield(field_name,field_value).
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
	logev("wait for kerbin:" + ship:body:name).
	wait until ship:body:name = "Kerbin".
}

set tset to 0.
lock throttle to tset. 

function do_sm_sep {


	if SHIP:ALTITUDE > 65000 {
		logev("- steer OUT").
		RCS ON.
		set side to R(10,10,0). 
		sas off.
		lock steering to lookdirup(ship:up:vector + side, ship:facing:topvector).
	}
	
	when VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR) < 20 or SHIP:ALTITUDE < 65000 then {
	
		logev("- SMjet in 5").
		set lestimestamp to time:seconds.

		when (time:seconds > (lestimestamp+5))or SHIP:ALTITUDE < 65000 then
		{
			logev("- SMjet").
			do_partmodule_event("SMJET_DEC","ModuleDecouple","decouple").
			do_partmodule_event("SMJET_DEC","ModuleAnimatedDecoupler","decouple").
			do_partmodule_event("SMJET_DEC","ModuleDockingNode","decouple node").
			RCS OFF.
			sas off.

			if SHIP:ALTITUDE < 65000{
				logev("- steer RG (2)").
				set g_roll_correction to -140.
				LOCK STEERING TO SHIP:SRFRETROGRADE + correctRoll. 
			}else{
				when SHIP:ALTITUDE < 65000 then {
					logev("- steer RG (3)").
					set g_roll_correction to -140.
					LOCK STEERING TO SHIP:SRFRETROGRADE + correctRoll. 
				}
			}
		}
	}
}

function check_for_sm_sep {

	if SHIP:PARTSDUBBED("SMJET_DEC"):LENGTH = 1 {
	
		logev("- waitfor sm_sep at 68000").
		when SHIP:ALTITUDE < 68000 then {

			if SHIP:PARTSDUBBED("SMJET_DEC"):LENGTH = 1 {
				do_sm_sep().
			}
		}
	}
		
	if SHIP:PARTSDUBBED("LAS"):LENGTH = 1 {
	
		logev("- waitfor las_sep at 63000").
		when SHIP:ALTITUDE < 63000 then {
			run las_jet.
		}
	}
		
	when SHIP:ALTITUDE < 63000 then {
		logev("- steer RG (4)").
		set g_roll_correction to -140.
		sas off.
		LOCK STEERING TO SHIP:SRFRETROGRADE + correctRoll. 
	}	
	
}

function do_deorbit {

	logev("- steer RG (for burn)").

	sas off.
	lock steering to lookdirup(ship:retrograde:vector, ship:facing:topvector).
	
	when VECTORANGLE(SHIP:RETROGRADE:VECTOR,SHIP:FACING:VECTOR) < 5 then {
	
		logev("- fire")..
		set tset to 1.
		
		when VECTORANGLE(SHIP:RETROGRADE:VECTOR,SHIP:FACING:VECTOR) > 6 or periapsis < deorbit_height or (ship:altitude < 65000 and periapsis < 60000) then {
			
			logev("- stop firing").
			set tset to 0.
			if (periapsis > deorbit_height)and((ship:altitude > 65000)or(periapsis > 60000)) {
				do_deorbit().
			}
		}
		

		when (periapsis < deorbit_height) and (throttle = 0) then {

			logev("- deorbit done").
			set kuniverse:timewarp:warp	to 4.
			when ship:altitude < 70000 and kuniverse:timewarp:mode = "PHYSICS" then {
				set kuniverse:timewarp:warp	to 4.
			}
			check_for_sm_sep().
			unlock steering.
			sas on.
		}

	}
	
	when (ship:altitude < 65000) and (periapsis < 60000) then {
		set tset to 0.
		check_for_sm_sep().
		unlock steering.
		sas on.
	}
}

if periapsis > deorbit_height {

	do_deorbit().
}
else
{
	logev("- deorbit good").
	check_for_sm_sep().
}

//SET g TO KERBIN:MU / KERBIN:RADIUS^2.
//function getLocalG {
//    return ship:body:mu / ship:body:position:mag ^ 2.
//	}
//LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.//needs Double-C & GRAVMAX Instruments
//LOCK gforce TO accvec:MAG / g.

//on round(time:seconds,1) {
//
//	if (ship:velocity:surface:mag < 1)or(ship:electriccharge < 3) {
//		return false.
//	}
//
//	log round(missiontime,2)+" "+round(ship:velocity:surface:mag,2)+" "+round(gforce,2)+" "+(round(radar_alt,2)/10000)+" " to "profile.txt".
//	//tail -1000 -f profile.txt | feedgnuplot --domain --terminal 'x11' -y2 1 --xlen 300 --stream 1 -ylabel speed -y2label g/alt*10k -y2 2
//	return true.
//}
		
when (radar_alt < 50000) and (ship:electriccharge < 15) then {

	local l_mod is "ModuleCommand".
	local l_field is "hibernation".
	FOR mypart IN SHIP:PARTS {
		if mypart:allmodules:contains(l_mod) {
			local mymod to mypart:getmodule(l_mod).
			if mymod:hasfield(l_field) {
				mymod:setfield(l_field,true).
			}
		}
	}
}

//todo: if electric charge < 2 : shut down everything (incl. kos) and arm chutes with safe parameters

WHEN (ship:velocity:surface:mag < 1900 ) and (radar_alt < 40000) then {

	logev("Arm D").
	arm_parachute("PARA_D1").
	arm_parachute("PARA_D2").

	WHEN (radar_alt < 6550) or (ship:electriccharge < 10) then {
		set kuniverse:timewarp:warp	to 1.
		logev("steer unlock").
		unlock steering.
		sas off.
		
	}

	WHEN radar_alt < 6500 and ship:velocity:surface:mag < 700 then {
		
		logev("Pre D").
		set_parachute_pressure("PARA_D1",0).
		set_parachute_pressure("PARA_D2",0).

		WHEN RADAR_alt < 3500  and ship:velocity:surface:mag < 500 then {
			SET WARP TO 2.
			logev("full d1").
			set_parachute_alt("PARA_D1",5000).
		}
		WHEN RADAR_alt < 1500  and ship:velocity:surface:mag < 500 then {
			SET WARP TO 1.
			logev("full d2 & cut D1").
			cut_parachute("PARA_D1").
			set_parachute_alt("PARA_D2",5000).
		}
			
		WHEN ship:velocity:surface:mag < 60 and  RADAR_alt < 1800 then {
			logev("HS Jet").
			do_partmodule_event("HS","ModuleDecouple","jettison heat shield").
		}
	
		WHEN radar_alt < 1000 and ship:velocity:surface:mag < 300 then {
			
			logev("Arm Main & Pre Main").
			arm_parachute("PARA_M1").
			arm_parachute("PARA_M2").
			arm_parachute("PARA_M3").
			arm_parachute("PARA_M4").
			set_parachute_pressure("PARA_M1",0).
			set_parachute_pressure("PARA_M2",0).
			set_parachute_pressure("PARA_M3",0).
			set_parachute_pressure("PARA_M4",0).

			WHEN RADAR_alt < 900  and ship:velocity:surface:mag < 250 then {
				SET WARP TO 0.
				logev("Cut D2 & Full 1").
				cut_parachute("PARA_D2").
				set_parachute_alt("PARA_M1",5000).
			}
			WHEN RADAR_alt < 600  and ship:velocity:surface:mag < 250 then {
				logev("Full 2").
				set_parachute_alt("PARA_M2",5000).
			}
			WHEN RADAR_alt < 400  and ship:velocity:surface:mag < 250 then {
				logev("Full 3").
				set_parachute_alt("PARA_M3",5000).
			}
			WHEN RADAR_alt < 100 and ship:velocity:surface:mag < 250 then {
				logev("Full 4").
				set_parachute_alt("PARA_M4",5000).

				when ship:velocity:surface:mag < 1 then {
					logev("Contact").
					print "------------------------".
					set prog_mode to 0.
				}
			}
		}
	}
}


