global hover_gui to gui(200).
global hover_events to lexicon().
global hover_active to false.

global hover_initial_height to 1. //set initial_height to 12.2.
global hover_max_angle to 35.
global hover_max_speed to 8.
global hover_curr_mode to "vel".
global hover_pitch to 0.
global hover_roll to 0.
global hover_lat1 to 0.
global hover_lat2 to 0.
global hover_lat3 to 0.
global hover_lng1 to 0.
global hover_lng2 to 0.
global hover_lng3 to 0.
global hover_target_v to 0.
global hover_target_h to 0.

global hover_PID TO PIDLOOP(0.237, 0.7, 0.005).
SET hover_PID:SETPOINT TO -600.
SET hover_PID:maxoutput TO 0.
SET hover_PID:minoutput TO 0.

global hover_PID2 TO PIDLOOP(0.6, 0, 0.12).
SET hover_PID2:SETPOINT TO hover_initial_height.
SET hover_PID2:maxoutput TO 400.
SET hover_PID2:minoutput TO -300.

global hover_PID_pitch TO PIDLOOP(15, 0.02, 0).
SET hover_PID_pitch:SETPOINT TO 0.
SET hover_PID_pitch:maxoutput TO hover_max_angle.
SET hover_PID_pitch:minoutput TO -hover_max_angle.

global hover_PID_roll TO PIDLOOP(15, 0.02, 0).
SET hover_PID_roll:SETPOINT TO 0.
SET hover_PID_roll:maxoutput TO hover_max_angle.
SET hover_PID_roll:minoutput TO -hover_max_angle.

global hover_PID_lat TO PIDLOOP(400, 0.2, 0).
SET hover_PID_lat:SETPOINT TO ship:geoposition:lat.
SET hover_PID_lat:maxoutput TO hover_max_speed.
SET hover_PID_lat:minoutput TO -hover_max_speed.

global hover_PID_lng TO PIDLOOP(400, 0.2, 0).
SET hover_PID_lng:SETPOINT TO ship:geoposition:lng.
SET hover_PID_lng:maxoutput TO hover_max_speed.
SET hover_PID_lng:minoutput TO -hover_max_speed.



function hover_init_gui {

	set hover_gui:x to 50.
	set hover_gui:y to 130.//von oben
	set hover_gui:skin:label:fontsize to 11.
	set hover_gui:skin:button:fontsize to 10.
	set hover_gui:skin:button:height to 15.


	hover_events:add("on",hover_gui:addbutton("On")).
	hover_events:add("off",hover_gui:addbutton("Off")).
	local hlayout1 to hover_gui:addhlayout().

	hover_events:add("vel",hlayout1:addbutton("Vel")).
	hover_events:add("gps",hlayout1:addbutton("GPS")).
	hover_events:add("free",hlayout1:addbutton("Free")).
	hover_events:add("mode",hover_gui:addlabel(hover_curr_mode)).

	hover_events:add("reboot",hover_gui:addbutton("Reboot")).

	local hlayout2 to hover_gui:addhlayout().
	hover_events:add("alt1",hlayout2:addlabel("Alt")).
	hover_events:add("alt2",hlayout2:addlabel("")).


	hover_events:add("plus05",hover_gui:addbutton("+0.5")).
	hover_events:add("minus05",hover_gui:addbutton("-0.5")).
	hover_events:add("hold",hover_gui:addbutton("Hold")).
	hover_events:add("plus5",hover_gui:addbutton("+5")).
	hover_events:add("minus5",hover_gui:addbutton("-5")).

	hover_events:add("initial",hover_gui:addbutton("to: "+hover_initial_height)).
	hover_events:add("to30",hover_gui:addbutton("to: 30")).
	hover_events:add("to200",hover_gui:addbutton("to: 200")).

	hover_events:add("vell",hover_gui:addlabel("Val")).
	hover_events:add("gpsl",hover_gui:addlabel("Gps")).
	hover_events:add("pl",hover_gui:addlabel("P"+hover_pid2:kp)).
	hover_events:add("psl",hover_gui:addhslider(hover_pid2:kp,0,8)).
	hover_events:add("il",hover_gui:addlabel("I"+hover_pid2:ki)).
	hover_events:add("isl",hover_gui:addhslider(hover_pid2:ki,0,2)).
	hover_events:add("dl",hover_gui:addlabel("D"+hover_pid2:kd)).
	hover_events:add("dsl",hover_gui:addhslider(hover_pid2:kd,0,0.5)).
	hover_events:add("pidl",hover_gui:addlabel("")).
	hover_events:add("longl",hover_gui:addlabel("0")).
	
}




function hover_check_buttons {

	if hover_events["vel"]:takepress {
		sas off.
		LOCK STEERING TO Up + R(hover_pitch,hover_roll,0).
		set hover_curr_mode to "vel".
		SET hover_PID_pitch:SETPOINT TO hover_target_v.
		SET hover_PID_roll:SETPOINT TO hover_target_h.
		set hover_events["mode"]:text to hover_curr_mode.
	}
	if hover_events["gps"]:takepress {
		sas off.
		LOCK STEERING TO Up + R(hover_pitch,hover_roll,0).
		set hover_curr_mode to "gps".
		set hover_events["mode"]:text to hover_curr_mode.
	}
	if hover_events["free"]:takepress {
		set hover_curr_mode to "free".
		unlock steering.
		SET SHIP:CONTROL:NEUTRALIZE to TRUE.
		sas on.
		set hover_events["mode"]:text to hover_curr_mode.
	}
	if hover_events["plus05"]:takepress {
		SET hover_PID2:SETPOINT TO hover_PID2:SETPOINT+0.5.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
	}
	if hover_events["minus05"]:takepress {
		SET hover_PID2:SETPOINT TO hover_PID2:SETPOINT-0.5.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
	}
	if hover_events["hold"]:takepress {
		SET hover_PID2:SETPOINT TO alt:radar.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
	}
	if hover_events["plus5"]:takepress {
		SET hover_PID2:SETPOINT TO hover_PID2:SETPOINT+5.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
	}
	if hover_events["minus5"]:takepress {
		SET hover_PID2:SETPOINT TO hover_PID2:SETPOINT-5.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
	}
	if hover_events["initial"]:takepress {
		SET hover_PID2:SETPOINT TO hover_initial_height.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
	}
	if hover_events["to30"]:takepress {
		SET hover_PID2:SETPOINT TO hover_initial_height+30.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
	}
	if hover_events["to200"]:takepress {
		SET hover_PID2:SETPOINT TO hover_initial_height+200.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
	}
	if hover_events["reboot"]:takepress {
		hover_gui:hide().
		reboot.
	}
	if hover_events["on"]:takepress {
		SET hover_PID_lat:SETPOINT TO ship:geoposition:lat.
		SET hover_PID_lng:SETPOINT TO ship:geoposition:lng.
		sas off.
		set hover_curr_mode to "vel".
		LOCK STEERING TO Up + R(hover_pitch,hover_roll,0).
		SET hover_PID:maxoutput TO 1.
		set hover_initial_height to alt:radar+0.6.
		//set initial_height to 0.
		SET hover_PID2:SETPOINT TO hover_initial_height.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
		lights on.
		when alt:radar+0.5 > hover_initial_height then gear off.
		//SET PID2:minoutput TO -3.
		
		set hover_target_v to 0.
		set hover_target_h to 0.
		
		SET hover_PID_pitch:SETPOINT TO hover_target_v.
		SET hover_PID_roll:SETPOINT TO hover_target_h.
	}
	if hover_events["off"]:takepress {
		local ok to 0.
		SET hover_PID2:SETPOINT TO hover_initial_height.
		set hover_events["alt1"]:text to "Alt:"+round(hover_PID2:SETPOINT,2).
		//SET PID2:minoutput TO -0.5.

		FOR mypart IN ship:parts {

			if ok = 0 and mypart:modules:contains("ModuleWheelDeployment") {

				set ok to 1.
	
				global testpart to mypart.

				when testpart:getmodule("ModuleWheelDeployment"):getfield("state") = "Deployed" then {
					SET hover_PID:maxoutput TO 0.
					lights off.
					unlock steering.
					sas off.
				}
			}
		}
		
		LOCK STEERING TO Up.

		gear on.
	}
}
function hover_start_control_loop2
{
	on round(time:seconds,1) {
		hover_check_buttons().
		
		set hover_events["alt2"]:text to "("+round(alt:radar,1)+" "+round(hover_PID2:SETPOINT,1)+")"+round(hover_pid2:minoutput,1).
		set hover_pid2:kp  to hover_Events["psl"]:value.
		set hover_pid2:ki  to hover_Events["isl"]:value.
		set hover_pid2:kd  to hover_Events["dsl"]:value.
		set hover_events["pl"]:text to "P"+round(hover_pid2:kp,4)+" "+round(hover_pid2:pterm,2).
		set hover_events["il"]:text to "I"+round(hover_pid2:ki,4)+" "+round(hover_pid2:iterm,2).
		set hover_events["dl"]:text to "D"+round(hover_pid2:kd,4)+" "+round(hover_pid2:dterm,2).
		set hover_events["pidl"]:text to "E"+round(hover_pid2:error,2)+" ES"+round(hover_pid2:errorsum,2).
		return true.
	}
}

function hover_start_control_loop
{
	global thrott TO 0.
	LOCK THROTTLE TO thrott.
	sas off.
	lock trueRadar to alt:radar - hover_PID2:SETPOINT.			// Offset radar to get distance from gear to ground
	lock g to constant:g * body:mass / body:radius^2.		// Gravity (m/s^2)
	lock maxDecel to (ship:availablethrust / ship:mass) - g.	// Maximum deceleration possible (m/s^2)
	lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		// The distance the burn will require
	lock idealThrottle to stopDist / trueRadar.			// Throttle required for perfect hoverslam

	when true then {


		set hover_pid2:maxoutput to sqrt(2*max(0,-1*trueRadar)*g).
		set hover_pid2:minoutput to -1*sqrt(0.92*2*maxDecel*max(1,trueRadar)).

		set hover_PID:SETPOINT TO hover_PID2:UPDATE(time:seconds,alt:radar).
		set thrott TO hover_PID:UPDATE(TIME:SECONDS,ship:verticalspeed) / sin(90-VECTORANGLE(SHIP:UP:VECTOR,SHIP:facing:VECTOR)).

		if (trueRadar < -2)and(ship:verticalspeed > 2) {
			set hover_pid:setpoint to sqrt(2*max(0,-1*trueRadar)*g).
		}
		if (trueRadar > 2)and(ship:verticalspeed < -2) {
			set hover_pid:setpoint to -1*sqrt(0.92*2*maxDecel*max(1,trueRadar)).
		}




		if not(hover_curr_mode = "free") {

			local topv to ship:velocity:surface * ship:facing:topvector.//fwd/back
			local sidev to ship:velocity:surface * ship:facing:starvector.//left/right

			set hover_pitch to hover_PID_pitch:update(time:seconds,-1*topv).
			set hover_roll to hover_PID_roll:update(time:seconds,sidev).
		
			if hover_curr_mode = "gps" {
				SET hover_PID_pitch:SETPOINT TO hover_PID_lat:update(time:seconds,ship:geoposition:lat).
				SET hover_PID_roll:SETPOINT TO -1*hover_PID_lng:update(time:seconds,ship:geoposition:lng).
			}
		}

		//tail -f pidtune.txt| feedgnuplot --terminal x11 --stream 0.2 --lines --domain --xlen 3 --legend 0 P --legend 1 I --legend 2 D --legend 3 E --ymin -1 --ymax 1
		//log round(missiontime,2)+" "+round(tunepid:pterm,2)+" "+round(tunepid:iterm,2)+" "+round(tunepid:dterm,2)+" "+round(-1*tunepid:error,2) to "0:/logs/pidtune.txt".

		return true.
	}
}

function hover_show_gui
{
	if hover_gui:widgets:length = 0 {
		hover_init_gui().
	}
	hover_gui:show().
	hover_start_control_loop().
	hover_start_control_loop2().
}

//when set1button:pressed then {
//	set lat1 to ship:geoposition:lat.
//	set lng1 to ship:geoposition:lng.
//	return true.
//}
//when set2button:pressed then {
//	set lat2 to ship:geoposition:lat.
//	set lng2 to ship:geoposition:lng.
//	return true.
//}
//when set3button:pressed then {
//	set lat3 to ship:geoposition:lat.
//	set lng3 to ship:geoposition:lng.
//	return true.
//}
//when rec1button:pressed then {
//	//-70.9572,-68.1388
//	SET PID_lat:SETPOINT TO -70.9572.
//	SET PID_lng:SETPOINT TO -68.1388.
//	return true.
//}
//when sidebutton:pressed then {
//	//-70.9572,-68.1388
//	SET PID_lat:SETPOINT TO  PID_lat:SETPOINT+0.002.
//	return true.
//}
//when rec2button:pressed then {
//	SET PID_lat:SETPOINT TO lat2.
//	SET PID_lng:SETPOINT TO lng2.
//	return true.
//}
//when rec3button:pressed then {
//	SET PID_lat:SETPOINT TO lat3.
//	SET PID_lng:SETPOINT TO lng3.
//	return true.
//}
//when lockbutton:pressed then {
//	SET PID_lat:SETPOINT TO ship:geoposition:lat.
//	SET PID_lng:SETPOINT TO ship:geoposition:lng.
//	LOCK STEERING TO Up + R(pitch,roll,0).
//	sas off.
//	return true.
//}

//when freebutton:pressed then {
//	unlock steering.
//	sas on.
//	return true.
//}
