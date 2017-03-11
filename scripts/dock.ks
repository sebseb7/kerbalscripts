// dont fail on dock
// start without target
// window open / close
// tuning pid_x y z
// sas switchable (start sas hold)
// save tuning vars per ship

global dock_gui to gui(200).
global gui_events to lexicon().

SET Kp_z TO 3.
SET Ki_z TO 0.
SET Kd_z TO 0.
global PID_z TO PIDLOOP(Kp_z, Ki_z, Kd_z).
SET PID_z:SETPOINT TO  0.
SET PID_z:maxoutput TO 0.25.
SET PID_z:minoutput TO -0.25.
SET Kp_y TO 3.
SET Ki_y TO 0.
SET Kd_y TO 0.
global PID_y TO PIDLOOP(Kp_y, Ki_y, Kd_y).
SET PID_y:SETPOINT TO  0.
SET PID_y:maxoutput TO 0.25.
SET PID_y:minoutput TO -0.25.
SET Kp_x TO 3.
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

global max_speed to 0.4.


when true then {

	if mode = "hold" {
		set speed_z to max(-1*max_speed,min(max_speed,0.2*((target_pos * ship:facing:forevector)-(offset_z1+offset_z)))).
		set speed_y to max(-1*max_speed,min(max_speed,0.2*((target_pos * ship:facing:topvector)-(offset_y1+offset_y)))).
		set speed_x to max(-1*max_speed,min(max_speed,0.2*((target_pos * ship:facing:starvector)-(offset_x1+offset_x)))).
		set PID_z:setpoint to -1 * speed_z.
		set PID_y:setpoint to -1 * speed_y.
		set PID_x:setpoint to -1 * speed_x.
	}

	set SHIP:CONTROL:FORE      to -1 * PID_z:UPDATE(TIME:SECONDS,(diff * ship:facing:forevector)).
	set SHIP:CONTROL:TOP       to -1 * PID_y:UPDATE(TIME:SECONDS,(diff * ship:facing:topvector)).
	set SHIP:CONTROL:STARBOARD to -1 * PID_x:UPDATE(TIME:SECONDS,(diff * ship:facing:starvector)).



	return true.
}



//function draw_ship_to_ship {
//  parameter
//      ship1,
//	      ship2,
//		      drawColor.
//
//			    local vdraw is vecdraw().
//				  set vdraw:start to ship1:position.
//				    set vdraw:vec to ship2:position - ship1:position.
//					  set vdraw:color to drawColor.
//					    set vdraw:show to true.
//						  return vdraw.
//						  }



function init_main_gui {

	set dock_gui:x to 50.
	set dock_gui:y to 130.//von oben
	local hlayout1 to dock_gui:addhlayout().
	gui_events:add("b_0rot",hlayout1:addbutton("0rot")).
	gui_events:add("b_steer_tgt",hlayout1:addbutton("Orb")).
	gui_events:add("b_steer_port",hlayout1:addbutton("Align")).
	gui_events:add("b_hold",dock_gui:addbutton("Hold")).
	gui_events:add("b_free",dock_gui:addbutton("Free")).
	gui_events:add("l_zpos",dock_gui:addlabel("z")).
	gui_events:add("f_zpos",dock_gui:ADDTEXTFIELD("x")).
	gui_events:add("l_ypos",dock_gui:addlabel("y")).
	gui_events:add("f_ypos",dock_gui:ADDTEXTFIELD("x")).
	gui_events:add("l_xpos",dock_gui:addlabel("x")).
	gui_events:add("f_xpos",dock_gui:ADDTEXTFIELD("x")).
	dock_gui:addlabel("roll").
	gui_events:add("f_roll",dock_gui:ADDTEXTFIELD(""+round(g_roll_correction,1))).
	dock_gui:addlabel("maxT").
	gui_events:add("f_maxt",dock_gui:ADDTEXTFIELD(""+round(0.25,2))).
	dock_gui:addlabel("maxS").
	gui_events:add("f_maxs",dock_gui:ADDTEXTFIELD(""+round(max_speed,2))).
	dock_gui:addlabel("KP").
	gui_events:add("f_kp",dock_gui:ADDTEXTFIELD(""+PID_x:kp)).
	gui_events:add("l_zsp",dock_gui:addlabel("z sp")).
	gui_events:add("l_ysp",dock_gui:addlabel("y sp")).
	gui_events:add("l_xsp",dock_gui:addlabel("x sp")).
	gui_events:add("b_retarget",dock_gui:addbutton("re-Target")).
	gui_events:add("b_end",dock_gui:addbutton("End")).

	set dock_gui:skin:label:fontsize to 15.
	set dock_gui:skin:button:fontsize to 10.
	set dock_gui:skin:button:height to 15.
}


function check_buttons {

	if gui_events["b_0rot"]:pressed {
		set my_facing to ship:facing.
	}
	if gui_events["b_steer_tgt"]:pressed {
		lock my_facing to target_obfac + R(0,0,g_roll_correction).
	}
	if gui_events["b_steer_port"]:pressed {
		lock my_facing to LOOKDIRUP(target_facing:forevector * -1,target_facing:topvector) + R(0,0,g_roll_correction).
	}

	if gui_events["f_zpos"]:confirmed {
		set offset_z to gui_events["f_zpos"]:text:tonumber.
	}
	if gui_events["f_ypos"]:confirmed {
		set offset_y to gui_events["f_ypos"]:text:tonumber.
	}
	if gui_events["f_xpos"]:confirmed {
		set offset_x to gui_events["f_xpos"]:text:tonumber.
	}
	if gui_events["f_roll"]:confirmed {
		set mode to "free".
		set gui_events["f_zpos"]:text to "x".
		set gui_events["f_ypos"]:text to "x".
		set gui_events["f_xpos"]:text to "x".
		set g_roll_correction to gui_events["f_roll"]:text:tonumber.
	}
	if gui_events["f_maxs"]:confirmed {
		set max_speed to gui_events["f_maxs"]:text:tonumber.
	}
	if gui_events["f_kp"]:confirmed {
		local kp to gui_events["f_kp"]:text:tonumber.
		set PID_x:kp to kp.
		set PID_y:kp to kp.
		set PID_z:kp to kp.
	}
		
	if gui_events["f_maxt"]:confirmed {
	
		local l_max_speed to gui_events["f_maxt"]:text:tonumber.

		SET PID_z:maxoutput TO l_max_speed.
		SET PID_z:minoutput TO -1 * l_max_speed.
		SET PID_y:maxoutput TO l_max_speed.
		SET PID_y:minoutput TO -1 * l_max_speed.
		SET PID_x:maxoutput TO l_max_speed.
		SET PID_x:minoutput TO -1 * l_max_speed.
	}


	if gui_events["b_end"]:pressed {
		global mode to "free".
		SET SHIP:CONTROL:NEUTRALIZE to TRUE.
		dock_gui:hide.
		unlock steerting.
		sas on.
		rcs off.
		set end to true.

		when true then {
			reboot.
		}

	}

	if gui_events["b_free"]:pressed {
		set mode to "free".
		set gui_events["f_zpos"]:text to "x".
		set gui_events["f_ypos"]:text to "x".
		set gui_events["f_xpos"]:text to "x".
	}

	if gui_events["b_hold"]:pressed {
		set mode to "hold".
		set offset_z to (target_pos * ship:facing:forevector)-offset_z1.
		set offset_y to (target_pos * ship:facing:topvector)-offset_y1.
		set offset_x to (target_pos * ship:facing:starvector)-offset_x1.
		set gui_events["f_zpos"]:text to ""+round(offset_z,2).
		set gui_events["f_ypos"]:text to ""+round(offset_y,2).
		set gui_events["f_xpos"]:text to ""+round(offset_x,2).
	}

	if gui_events["b_retarget"]:pressed {

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
			dock_gui:hide.
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
		set gui_events["f_zpos"]:text to "x".
		set gui_events["f_ypos"]:text to "x".
		set gui_events["f_xpos"]:text to "x".
		

		logev("tar").
		//set targetpart to target.
	}
}


on round(time:seconds,1) {

	check_buttons().
	set gui_events["l_zpos"]:text to "z "+round((target_pos * ship:facing:forevector)-offset_z1,2).
	set gui_events["l_ypos"]:text to "y "+round((target_pos * ship:facing:topvector)-offset_y1,2).
	set gui_events["l_xpos"]:text to "x "+round((target_pos * ship:facing:starvector)-offset_x1,2).
	
	set gui_events["l_zsp"]:text to "z sp "+round(diff * ship:facing:forevector,2)+" tg "+round(-1 * speed_z,2)+" ac "+round(PID_z:output,2).
	set gui_events["l_ysp"]:text to "y sp "+round(diff * ship:facing:topvector,2)+" tg "+round(-1 * speed_y,2)+"  ac "+round(PID_y:output,2).
	set gui_events["l_xsp"]:text to "x sp "+round(diff * ship:facing:starvector,2)+" tg "+round(-1 * speed_x,2)+"  ac "+round(PID_x:output,2).
	
	
	if mode = "free" {
		set PID_z:setpoint to 0.
		set PID_y:setpoint to 0.
		set PID_x:setpoint to 0.
	}
	
	
	
	if ship:controlpart:typename = "DockingPort" {
		//print "port".
		//print ship:controlpart:state.
		if ship:controlpart:state = "Acquire" {
			print "aq".
			logev("endtug").
		
			global mode to "free".
			SET SHIP:CONTROL:NEUTRALIZE to TRUE.
			dock_gui:hide.
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

if dock_gui:widgets:length = 0 {
	init_main_gui().
}

dock_gui:show().



