// dont fail on dock
// start without target
// window open / close
// tuning pid_x y z
// sas switchable (start sas hold)
// save tuning vars per ship

SET Kp_z TO 1.
SET Ki_z TO 0.
SET Kd_z TO 0.
global PID_z TO PIDLOOP(Kp_z, Ki_z, Kd_z).
SET PID_z:SETPOINT TO  0.
SET PID_z:maxoutput TO 0.25.
SET PID_z:minoutput TO -0.25.
SET Kp_y TO 1.
SET Ki_y TO 0.
SET Kd_y TO 0.
global PID_y TO PIDLOOP(Kp_y, Ki_y, Kd_y).
SET PID_y:SETPOINT TO  0.
SET PID_y:maxoutput TO 0.25.
SET PID_y:minoutput TO -0.25.
SET Kp_x TO 1.
SET Ki_x TO 0.
SET Kd_x TO 0.
global PID_x TO PIDLOOP(Kp_x, Ki_x, Kd_x).
SET PID_x:SETPOINT TO  0.
SET PID_x:maxoutput TO 0.25.
SET PID_x:minoutput TO -0.25.

global end to false.


sas off.
rcs on.

global mode to "free".

//print ship:position.
print target:portfacing.

global targetpart to target.

global speed_x to 0.
global speed_y to 0.
global speed_z to 0.

global diff to 0.
lock diff to targetpart:ship:velocity:orbit - ship:velocity:orbit.


global offset_z to (targetpart:nodeposition * ship:facing:forevector).
global offset_y to (targetpart:nodeposition * ship:facing:topvector).
global offset_x to (targetpart:nodeposition * ship:facing:starvector).

global g_roll_correction to 0.

lock steering to (targetpart:portfacing:vector * -1):direction + R(0,0,g_roll_correction).

global max_speed to 0.1.


when true then {

	set speed_z to max(-1*max_speed,min(max_speed,(targetpart:nodeposition * ship:facing:forevector)-offset_z)).
	set speed_y to max(-1*max_speed,min(max_speed,(targetpart:nodeposition * ship:facing:topvector)-offset_y)).
	set speed_x to max(-1*max_speed,min(max_speed,(targetpart:nodeposition * ship:facing:starvector)-offset_x)).

	set PID_z:setpoint to -1 * speed_z.
	set PID_y:setpoint to -1 * speed_y.
	set PID_x:setpoint to -1 * speed_x.

	if mode = "hold" {
		set SHIP:CONTROL:FORE      to -1 * PID_z:UPDATE(TIME:SECONDS,(diff * ship:facing:forevector)).
		set SHIP:CONTROL:TOP       to -1 * PID_y:UPDATE(TIME:SECONDS,(diff * ship:facing:topvector)).
		set SHIP:CONTROL:STARBOARD to -1 * PID_x:UPDATE(TIME:SECONDS,(diff * ship:facing:starvector)).
	}

	return true.
}

on target {
	logev("tar").
	set targetpart to target.
	return true.
}

on round(time:seconds,1) {
	set zposlabel:text to "z "++round((targetpart:nodeposition * ship:facing:forevector),2).
	set yposlabel:text to "y "++round((targetpart:nodeposition * ship:facing:topvector),2).
	set xposlabel:text to "x "++round((targetpart:nodeposition * ship:facing:starvector),2).
	
	set zsplabel:text to "z sp "+round(diff * ship:facing:forevector,2)+" tg "+round(speed_z,2).
	set ysplabel:text to "y sp "+round(diff * ship:facing:topvector,2)+" tg "+round(speed_y,2).
	set xsplabel:text to "x sp "+round(diff * ship:facing:starvector,2)+" tg "+round(speed_x,2).


	return true.
}

global hgui to gui(200).
set hgui:x to 50.
set hgui:y to 130.//von oben
hgui:show().
global holdbutton to hgui:addbutton("Hold").
global freebutton to hgui:addbutton("Free").
global zposlabel to hgui:addlabel("z").
global zposfield to hgui:ADDTEXTFIELD(""+round(offset_z,1)).
global yposlabel to hgui:addlabel("y").
global yposfield to hgui:ADDTEXTFIELD(""+round(offset_y,1)).
global xposlabel to hgui:addlabel("x").
global xposfield to hgui:ADDTEXTFIELD(""+round(offset_x,1)).
hgui:addlabel("roll").
global rollfield to hgui:ADDTEXTFIELD(""+round(g_roll_correction,1)).
hgui:addlabel("maxT").
global maxfield to hgui:ADDTEXTFIELD(""+round(0.25,2)).
hgui:addlabel("maxS").
global maxsfield to hgui:ADDTEXTFIELD(""+round(max_speed,2)).
hgui:addlabel("P").
global kpfield to hgui:ADDTEXTFIELD(""+PID_x:kp).
global zsplabel to hgui:addlabel("z sp").
global ysplabel to hgui:addlabel("y sp").
global xsplabel to hgui:addlabel("x sp").
global endbutton to hgui:addbutton("End").


when zposfield:confirmed then {
	set offset_z to zposfield:text:tonumber.
	return true.
}
when yposfield:confirmed then {
	set offset_y to yposfield:text:tonumber.
	return true.
}
when xposfield:confirmed then {
	set offset_x to xposfield:text:tonumber.
	return true.
}
when rollfield:confirmed then {
	set g_roll_correction to rollfield:text:tonumber.
	return true.
}
when maxsfield:confirmed then {
	set max_speed to maxsfield:text:tonumber.
	return true.
}
when kpfield:confirmed then {
	set PID_x:kp to kpfield:text:tonumber.
	set PID_y:kp to kpfield:text:tonumber.
	set PID_z:kp to kpfield:text:tonumber.
	return true.
}
	
when maxfield:confirmed then {
	SET PID_z:maxoutput TO maxfield:text:tonumber.
	SET PID_z:minoutput TO -1 * maxfield:text:tonumber.
	SET PID_y:maxoutput TO maxfield:text:tonumber.
	SET PID_y:minoutput TO -1 * maxfield:text:tonumber.
	SET PID_x:maxoutput TO maxfield:text:tonumber.
	SET PID_x:minoutput TO -1 * maxfield:text:tonumber.
	return true.
}


when endbutton:pressed then {
	global mode to "free".
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	hgui:hide.
	unlock steerting.
	sas on.
	rcs off.
	set end to true.
	return true.
}

when freebutton:pressed then {
	set mode to "free".
	SET SHIP:CONTROL:NEUTRALIZE to TRUE.
	return true.
}
when holdbutton:pressed then {
	set mode to "hold".
	set offset_z to (targetpart:nodeposition * ship:facing:forevector).
	set offset_y to (targetpart:nodeposition * ship:facing:topvector).
	set offset_x to (targetpart:nodeposition * ship:facing:starvector).
	set zposfield:text to ""+round(offset_z,1).
	set yposfield:text to ""+round(offset_y,1).
	set xposfield:text to ""+round(offset_x,1).
	return true.
}


