//set initial_height to 12.2.
set initial_height to 1.

set max_angle to 1.5.
//set max_angle to 35.


set max_speed to 8.

SET Kp TO 0.237.
SET Ki TO 0.7.
SET Kd TO 0.005.
SET PID TO PIDLOOP(Kp, Ki, Kd).
SET PID:SETPOINT TO -600.
SET PID:maxoutput TO 0.
SET PID:minoutput TO 0.

SET Kp2 TO 2.0.
SET Ki2 TO 0.0.
SET Kd2 TO 0.12.
SET PID2 TO PIDLOOP(Kp2, Ki2, Kd2).
SET PID2:SETPOINT TO initial_height.
SET PID2:maxoutput TO 400.
SET PID2:minoutput TO -300.

SET Kp_pitch TO 15.0.
SET Ki_pitch TO 0.02.
SET Kd_pitch TO 0.000.
SET PID_pitch TO PIDLOOP(Kp_pitch, Ki_pitch, Kd_pitch).
SET PID_pitch:SETPOINT TO 0.
SET PID_pitch:maxoutput TO max_angle.
SET PID_pitch:minoutput TO -max_angle.

SET Kp_roll TO 15.0.
SET Ki_roll TO 0.02.
SET Kd_roll TO 0.000.
SET PID_roll TO PIDLOOP(Kp_roll, Ki_roll, Kd_roll).
SET PID_roll:SETPOINT TO 0.
SET PID_roll:maxoutput TO max_angle.
SET PID_roll:minoutput TO -max_angle.


SET Kp_lat TO 400.0.
SET Ki_lat TO 0.2.
SET Kd_lat TO 0.000.
SET PID_lat TO PIDLOOP(Kp_lat, Ki_lat, Kd_lat).
SET PID_lat:SETPOINT TO ship:geoposition:lat.
SET PID_lat:maxoutput TO max_speed.
SET PID_lat:minoutput TO -max_speed.

SET Kp_lng TO 400.0.
SET Ki_lng TO 0.2.
SET Kd_lng TO 0.000.
SET PID_lng TO PIDLOOP(Kp_lng, Ki_lng, Kd_lng).
SET PID_lng:SETPOINT TO ship:geoposition:lng.
SET PID_lng:maxoutput TO max_speed.
SET PID_lng:minoutput TO -max_speed.


set tunepid to pid2.

SET thrott TO 0.
LOCK THROTTLE TO thrott.

set pitch to 0.
set roll to 0.

sas off.

set curr_mode to "vel".

set hgui to gui(200).
set hgui:x to 50.
set hgui:y to 130.//von oben
hgui:show().
set onbutton to hgui:addbutton("On").
set offbutton to hgui:addbutton("Off").
set hlayout1 to hgui:addhlayout().
set modevbutton to hlayout1:addbutton("Vel").
set modegbutton to hlayout1:addbutton("Gps").
set modefbutton to hlayout1:addbutton("Free").
set modelabel to hlayout1:addlabel(curr_mode).
set rebootbutton to hgui:addbutton("reboot").
set hlayout2 to hgui:addhlayout().
set altlabel to hlayout2:addlabel("Alt").
set altlabel2 to hlayout2:addlabel("").
set upbutton to hgui:addbutton("+0.5").
set downbutton to hgui:addbutton("-0.5").
set currbutton to hgui:addbutton("curr").
set up2button to hgui:addbutton("+5").
set down2button to hgui:addbutton("-5").
set zerobutton to hgui:addbutton("to: "+initial_height).
set thirtybutton to hgui:addbutton("to: 30").
set onekbutton to hgui:addbutton("to: 1000").
hgui:addlabel("Vel").
hgui:addlabel("Gps").
set plabel to hgui:addlabel("P").
set pslider to hgui:addhslider(0,8).
set ilabel to hgui:addlabel("I").
set islider to hgui:addhslider(0,2).
set dlabel to hgui:addlabel("D").
set dslider to hgui:addhslider(0,0.5).
set pidlabel to hgui:addlabel("").

set pslider:value to tunepid:kp.
set plabel:text to "P"+tunepid:kp.
set islider:value to tunepid:ki.
set ilabel:text to "I"+tunepid:ki.
set dslider:value to tunepid:kd.
set dlabel:text to "D"+tunepid:kd.



set lat1 to 0.
set lat2 to 0.
set lat3 to 0.
set lng1 to 0.
set lng2 to 0.
set lng3 to 0.


set target_v to 0.
set target_h to 0.
//when fwdbutton:pressed then {
//	SET PID_pitch:SETPOINT TO PID_pitch:SETPOINT+0.5.
//	return true.
//}

when modevbutton:pressed then {

	sas off.
	LOCK STEERING TO Up + R(pitch,roll,0).
	set curr_mode to "vel".
	set modelabel:text to curr_mode.
	SET PID_pitch:SETPOINT TO target_v.
	SET PID_roll:SETPOINT TO target_h.
	return true.
}
when modegbutton:pressed then {

	sas off.
	LOCK STEERING TO Up + R(pitch,roll,0).
	set curr_mode to "gps".
	set modelabel:text to curr_mode.
	return true.
}
when modefbutton:pressed then {

	set curr_mode to "free".
	unlock steering.
	sas on.
	set modelabel:text to curr_mode.
	return true.
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

when upbutton:pressed then {
	
	SET PID2:SETPOINT TO PID2:SETPOINT+0.5.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	return true.
}
when currbutton:pressed then {
	
	SET PID2:SETPOINT TO alt:radar.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	return true.
}
when up2button:pressed then {
	
	SET PID2:SETPOINT TO PID2:SETPOINT+5.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	return true.
}
when rebootbutton:pressed then {
	hgui:hide().
	reboot.
}
when downbutton:pressed then {
	
	SET PID2:SETPOINT TO PID2:SETPOINT-0.5.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	return true.
}
when down2button:pressed then {
	
	SET PID2:SETPOINT TO PID2:SETPOINT-5.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	return true.
}
when zerobutton:pressed then {
	
	SET PID2:SETPOINT TO initial_height.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	return true.
}
when thirtybutton:pressed then {
	
	SET PID2:SETPOINT TO initial_height+30.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	return true.
}
when onekbutton:pressed then {
	
	SET PID2:SETPOINT TO initial_height+1000.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	return true.
}
when onbutton:pressed then {
	
	SET PID_lat:SETPOINT TO ship:geoposition:lat.
	SET PID_lng:SETPOINT TO ship:geoposition:lng.
	sas off.
	set curr_mode to "vel".
	LOCK STEERING TO Up + R(pitch,roll,0).
	SET PID:maxoutput TO 1.
	set initial_height to alt:radar+0.6.
	//set initial_height to 0.
	SET PID2:SETPOINT TO initial_height.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	set zerobutton:text to "to: "+round(initial_height,2).
	lights on.
	when alt:radar+0.5 > initial_height then gear off.
	//SET PID2:minoutput TO -3.
	
	set target_v to 0.
	set target_h to 0.
	
	SET PID_pitch:SETPOINT TO target_v.
	SET PID_roll:SETPOINT TO target_h.
	return true.
}
when offbutton:pressed then {
	
	set ok to 0.
	SET PID2:SETPOINT TO initial_height.
	set altlabel:text to "Alt:"+round(PID2:SETPOINT,2).
	//SET PID2:minoutput TO -0.5.

	FOR mypart IN ship:parts {

		if ok = 0 and mypart:modules:contains("ModuleWheelDeployment") {

			set ok to 1.

			global testpart to mypart.

			when testpart:getmodule("ModuleWheelDeployment"):getfield("state") = "Deployed" then {
				SET PID:maxoutput TO 0.
				lights off.
				unlock steering.
				sas off.
			}
		}
	}
	
	LOCK STEERING TO Up.

	gear on.
	return true.
}
lock trueRadar to alt:radar - PID2:SETPOINT.			// Offset radar to get distance from gear to ground
lock g to constant:g * body:mass / body:radius^2.		// Gravity (m/s^2)
lock maxDecel to (ship:availablethrust / ship:mass) - g.	// Maximum deceleration possible (m/s^2)
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		// The distance the burn will require
lock idealThrottle to stopDist / trueRadar.			// Throttle required for perfect hoverslam

UNTIL false {

	set pid2:maxoutput to sqrt(2*max(0,-1*trueRadar)*g).
	set pid2:minoutput to -1*sqrt(0.92*2*maxDecel*max(1,trueRadar)).

	//set PID:SETPOINT TO min(2000,max(-400,-1*(alt:radar-PID2:SETPOINT))).
	set PID:SETPOINT TO PID2:UPDATE(time:seconds,alt:radar).
	//set PID:SETPOINT TO PID2:SETPOINT.
	set thrott TO PID:UPDATE(TIME:SECONDS,ship:verticalspeed) / sin(90-VECTORANGLE(SHIP:UP:VECTOR,SHIP:facing:VECTOR)).

	set modex to ""+round(pid2:minoutput,1).

	if (trueRadar < -2)and(ship:verticalspeed > 2) {
		set pid:setpoint to sqrt(2*max(0,-1*trueRadar)*g).
	}
	if (trueRadar > 2)and(ship:verticalspeed < -2) {
		set pid:setpoint to -1*sqrt(0.92*2*maxDecel*max(1,trueRadar)).
	}


	if (ship:verticalspeed < -0.5)and(trueRadar > 0.5) {
		//set thrott to idealThrottle*idealThrottle*idealThrottle.
		//set modex to "v".
	}

	
	set altlabel2:text to "("+round(alt:radar,1)+" "+round(PID2:SETPOINT,1)+")"+modex.

	set tunepid:kp  to pslider:value.
	set tunepid:ki  to islider:value.
	set tunepid:kd  to dslider:value.

	set plabel:text to "P"+round(tunepid:kp,4)+" "+round(pid:pterm,2).
	set ilabel:text to "I"+round(tunepid:ki,4)+" "+round(pid:iterm,2).
	set dlabel:text to "D"+round(tunepid:kd,4)+" "+round(pid:dterm,2).
	set pidlabel:text to "E"+round(tunepid:error,2)+" ES"+round(tunepid:errorsum,2).

	if not(curr_mode = "free") {

		set topv to ship:velocity:surface * ship:facing:topvector.//fwd/back
		set sidev to ship:velocity:surface * ship:facing:starvector.//left/right


		//set pitch to -1*PID_pitch:update(time:seconds,topv).
		set pitch to PID_pitch:update(time:seconds,-1*topv).
		set roll to PID_roll:update(time:seconds,sidev).

		//print topv+" : "+sidev.
		
	
		if curr_mode = "gps" {
			SET PID_pitch:SETPOINT TO PID_lat:update(time:seconds,ship:geoposition:lat).
			SET PID_roll:SETPOINT TO -1*PID_lng:update(time:seconds,ship:geoposition:lng).
		}
	}

//	print "lat:"+ship:geoposition:lat.
//	print "lng:"+ship:geoposition:lng.
//	print "latset:"+PID_lat:setpoint.
//	print "lngset:"+PID_lng:setpoint.
//	print "pit:"+PID_pitch:setpoint.
//	print "rolt:"+PID_roll:setpoint.
	
	//tail -f pidtune.txt| feedgnuplot --terminal x11 --stream 0.2 --lines --domain --xlen 3 --legend 0 P --legend 1 I --legend 2 D --legend 3 E --ymin -1 --ymax 1
	log round(missiontime,2)+" "+round(tunepid:pterm,2)+" "+round(tunepid:iterm,2)+" "+round(tunepid:dterm,2)+" "+round(-1*tunepid:error,2) to "0:/logs/pidtune.txt".

	WAIT 0.001.
}

