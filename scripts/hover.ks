SET Kp TO 0.8.
SET Ki TO 0.003.
SET Kd TO 0.002.
SET PID TO PIDLOOP(Kp, Ki, Kd).
SET PID:SETPOINT TO -600.
SET PID:maxoutput TO 0.
SET PID:minoutput TO 0.

SET Kp2 TO 1.0.
SET Ki2 TO 0.2.
SET Kd2 TO 0.006.
SET PID2 TO PIDLOOP(Kp2, Ki2, Kd2).
SET PID2:SETPOINT TO 1.
SET PID2:maxoutput TO 6.
SET PID2:minoutput TO -3.

SET Kp_pitch TO 15.0.
SET Ki_pitch TO 0.02.
SET Kd_pitch TO 0.000.
SET PID_pitch TO PIDLOOP(Kp_pitch, Ki_pitch, Kd_pitch).
SET PID_pitch:SETPOINT TO 0.
SET PID_pitch:maxoutput TO 45.
SET PID_pitch:minoutput TO -45.

SET Kp_roll TO 15.0.
SET Ki_roll TO 0.02.
SET Kd_roll TO 0.000.
SET PID_roll TO PIDLOOP(Kp_roll, Ki_roll, Kd_roll).
SET PID_roll:SETPOINT TO 0.
SET PID_roll:maxoutput TO 45.
SET PID_roll:minoutput TO -45.

SET thrott TO 0.
LOCK THROTTLE TO thrott.

set pitch to 0.
set roll to 0.
set yaw to 0.

LOCK STEERING TO Up + R(pitch,roll,yaw).
sas off.


set hgui to gui(200).
set hgui:x to 50.
set hgui:y to 130.//von oben
hgui:show().
set onbutton to hgui:addbutton("On").
set offbutton to hgui:addbutton("Off").
set upbutton to hgui:addbutton("+0.5").
set downbutton to hgui:addbutton("-0.5").
set zerobutton to hgui:addbutton("to: 0.5").
set freebutton to hgui:addbutton("steerfree").
set fwdbutton to hgui:addbutton("forward +0.5").
set lockbutton to hgui:addbutton("lock steer to 0").
set yawslider to hgui:addhslider(1,360).
set rebootbutton to hgui:addbutton("reboot").

when fwdbutton:pressed then {
	SET PID_pitch:SETPOINT TO PID_pitch:SETPOINT+0.5.
	return true.
}

when lockbutton:pressed then {
	LOCK STEERING TO Up + R(pitch,roll,yaw).
	SET PID_pitch:SETPOINT TO 0.
	sas off.
	return true.
}

when freebutton:pressed then {
	sas on.
	unlock steering.
	return true.
}

when upbutton:pressed then {
	
	SET PID2:SETPOINT TO PID2:SETPOINT+0.5.
	return true.
}
when rebootbutton:pressed then {
	hgui:hide().
	reboot.
}
when downbutton:pressed then {
	
	SET PID2:SETPOINT TO PID2:SETPOINT-0.5.
	return true.
}
when zerobutton:pressed then {
	
	SET PID2:SETPOINT TO 1.
	return true.
}
when onbutton:pressed then {
	
	SET PID:maxoutput TO 1.
	SET PID2:SETPOINT TO 1.
	lights on.
	gear off.
	return true.
}
when offbutton:pressed then {
	
	set ok to 0.

	FOR mypart IN ship:parts {

		if ok = 0 and mypart:modules:contains("ModuleWheelDeployment") {

			set ok to 1.

			global testpart to mypart.

			when testpart:getmodule("ModuleWheelDeployment"):getfield("state") = "Deployed" then {
				SET PID:maxoutput TO 0.
				lights off.
			}
		}
	}

	gear on.
	return true.
}
UNTIL false {

	set thrott TO PID:UPDATE(TIME:SECONDS,ship:verticalspeed) / sin(90-VECTORANGLE(SHIP:UP:VECTOR,SHIP:facing:VECTOR)).

	set PID:SETPOINT TO -1*(alt:radar-PID2:SETPOINT).
	
	set topv to ship:velocity:surface * ship:facing:topvector.//fwd/back
	set sidev to ship:velocity:surface * ship:facing:starvector.//left/right


	set pitch to -1*PID_pitch:update(time:seconds,topv).
	set roll to PID_roll:update(time:seconds,sidev).

	set yaw to yawslider:value.
	
	WAIT 0.001.
}

