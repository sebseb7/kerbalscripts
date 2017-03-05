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


if not(HASTARGET){
	logev("notar").
	reboot.
}
if not(ship:controlpart:typename="DockingPort"){
	logev("nodock").
	reboot.
}

global cpart to ship:controlpart.

sas off.
rcs on.

global mode to "free".
	
global target_pos to 0.
global target_orbit to 0.
global target_obfac to 0.
global target_facing to 0.
global my_facing to 0.
	
global my_target to target.

if target:typename = "Vessel" {


	lock target_pos to my_target:rootpart:position.
	lock target_orbit to my_target:velocity:orbit.
	lock target_obfac to my_target:facing.
	lock target_facing to my_target:facing.
	set my_facing to ship:facing.

}
if target:typename = "DockingPort" {

	lock target_pos to my_target:nodeposition.
	lock target_orbit to my_target:ship:velocity:orbit.
	lock target_obfac to my_target:ship:facing.
	lock target_facing to my_target:portfacing.
	set my_facing to ship:facing.

}


//print target:portfacing.
//(my_facing:vector * -1):direction + R(0,0,g_roll_correction).


global speed_x to 0.
global speed_y to 0.
global speed_z to 0.

global diff to 0.

lock diff to target_orbit - ship:velocity:orbit.
//lock diff to target_orbit - cpart:portfacing:forevector.

lock offset_z1 to (cpart:nodeposition * ship:facing:forevector).
lock offset_y1 to (cpart:nodeposition * ship:facing:topvector).
lock offset_x1 to (cpart:nodeposition * ship:facing:starvector).


global offset_z to 0.
global offset_y to 0.
global offset_x to 0.

global g_roll_correction to 0.

lock steering to my_facing.

global max_speed to 0.1.


when true then {

	if mode = "hold" {
		set speed_z to max(-1*max_speed,min(max_speed,0.4*((target_pos * ship:facing:forevector)-(offset_z1+offset_z)))).
		set speed_y to max(-1*max_speed,min(max_speed,0.4*((target_pos * ship:facing:topvector)-(offset_y1+offset_y)))).
		set speed_x to max(-1*max_speed,min(max_speed,0.4*((target_pos * ship:facing:starvector)-(offset_x1+offset_x)))).
		set PID_z:setpoint to -1 * speed_z.
		set PID_y:setpoint to -1 * speed_y.
		set PID_x:setpoint to -1 * speed_x.
	}
	if mode = "free" {
		set PID_z:setpoint to 0.
		set PID_y:setpoint to 0.
		set PID_x:setpoint to 0.
	}

	set SHIP:CONTROL:FORE      to -1 * PID_z:UPDATE(TIME:SECONDS,(diff * ship:facing:forevector)).
	set SHIP:CONTROL:TOP       to -1 * PID_y:UPDATE(TIME:SECONDS,(diff * ship:facing:topvector)).
	set SHIP:CONTROL:STARBOARD to -1 * PID_x:UPDATE(TIME:SECONDS,(diff * ship:facing:starvector)).


	if ship:controlpart:typename = "DockingPort" {
		print "port".
		print ship:controlpart:state.
		if ship:controlpart:state = "Acquire" {
			print "aq".
			logev("endtug").
		
			global mode to "free".
			SET SHIP:CONTROL:NEUTRALIZE to TRUE.
			hgui:hide.
			unlock steerting.
			sas on.
			rcs off.
			set end to true.

			when true then {
				reboot.
			}
		}
	}

	return true.
}


on round(time:seconds,1) {
	set zposlabel:text to "z "+round((target_pos * ship:facing:forevector)-offset_z1,2).
	set yposlabel:text to "y "+round((target_pos * ship:facing:topvector)-offset_y1,2).
	set xposlabel:text to "x "+round((target_pos * ship:facing:starvector)-offset_x1,2).
	
	set zsplabel:text to "z sp "+round(diff * ship:facing:forevector,2)+" tg "+round(-1 * speed_z,2)+" ac "+round(PID_z:output,2).
	set ysplabel:text to "y sp "+round(diff * ship:facing:topvector,2)+" tg "+round(-1 * speed_y,2)+"  ac "+round(PID_y:output,2).
	set xsplabel:text to "x sp "+round(diff * ship:facing:starvector,2)+" tg "+round(-1 * speed_x,2)+"  ac "+round(PID_x:output,2).


	return true.
}

global hgui to gui(200).
set hgui:x to 50.
set hgui:y to 130.//von oben
hgui:show().
set hlayout1 to hgui:addhlayout().
global steer_hold to hlayout1:addbutton("0rot").
global steer_tgt to hlayout1:addbutton("Orb").
global steer_port to hlayout1:addbutton("Align").
global holdbutton to hgui:addbutton("Hold").
global freebutton to hgui:addbutton("Free").
global zposlabel to hgui:addlabel("z").
global zposfield to hgui:ADDTEXTFIELD("x").
global yposlabel to hgui:addlabel("y").
global yposfield to hgui:ADDTEXTFIELD("x").
global xposlabel to hgui:addlabel("x").
global xposfield to hgui:ADDTEXTFIELD("x").
hgui:addlabel("roll").
global rollfield to hgui:ADDTEXTFIELD(""+round(g_roll_correction,1)).
hgui:addlabel("maxT").
global maxfield to hgui:ADDTEXTFIELD(""+round(0.25,2)).
hgui:addlabel("maxS").
global maxsfield to hgui:ADDTEXTFIELD(""+round(max_speed,2)).
hgui:addlabel("KP").
global kpfield to hgui:ADDTEXTFIELD(""+PID_x:kp).
global zsplabel to hgui:addlabel("z sp").
global ysplabel to hgui:addlabel("y sp").
global xsplabel to hgui:addlabel("x sp").
global retargetbutton to hgui:addbutton("re-Target").
global endbutton to hgui:addbutton("End").

when steer_hold:pressed then {
	set my_facing to ship:facing.
	return true.
}
when steer_tgt:pressed then {
	lock my_facing to target_obfac + R(0,0,g_roll_correction).
	return true.
}
when steer_port:pressed then {
	lock my_facing to LOOKDIRUP(target_facing:forevector * -1,target_facing:topvector) + R(0,0,g_roll_correction).
	return true.
}

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
	set mode to "free".
	set zposfield:text to "x".
	set yposfield:text to "x".
	set xposfield:text to "x".
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

	when true then {
		reboot.
	}

	return true.
}

when freebutton:pressed then {
	set mode to "free".
	set zposfield:text to "x".
	set yposfield:text to "x".
	set xposfield:text to "x".
	return true.
}
when holdbutton:pressed then {
	set mode to "hold".
	set offset_z to (target_pos * ship:facing:forevector)-offset_z1.
	set offset_y to (target_pos * ship:facing:topvector)-offset_y1.
	set offset_x to (target_pos * ship:facing:starvector)-offset_x1.
	set zposfield:text to ""+round(offset_z,2).
	set yposfield:text to ""+round(offset_y,2).
	set xposfield:text to ""+round(offset_x,2).
	return true.
}

when retargetbutton:pressed then {

	global my_target to target.

	if target:typename = "Vessel" {

		lock target_pos to my_target:rootpart:position.
		lock target_orbit to my_target:velocity:orbit.
		lock target_obfac to my_target:facing.
		lock target_facing to my_target:facing.
		set my_facing to ship:facing.
	}
	else if target:typename = "DockingPort" {

		lock target_pos to my_target:nodeposition.
		lock target_orbit to my_target:ship:velocity:orbit.
		lock target_obfac to my_target:ship:facing.
		lock target_facing to my_target:portfacing.
		set my_facing to ship:facing.
	}else{
		global mode to "free".
		SET SHIP:CONTROL:NEUTRALIZE to TRUE.
		hgui:hide.
		unlock steerting.
		sas on.
		rcs off.
		set end to true.

		when true then {
			reboot.
		}
	}
		
	set mode to "free".
	set offset_z to 0.
	set offset_y to 0.
	set offset_x to 0.
	set zposfield:text to "x".
	set yposfield:text to "x".
	set xposfield:text to "x".
	

	logev("tar").
	//set targetpart to target.
	return true.
}

