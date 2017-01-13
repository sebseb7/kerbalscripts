// launch to orbit (w/ atmosphere)

if body:name = "Kerbin" {

	set lorb to 80000.
	set ha to 59000.
	set vac to 70000.

	set angle to 12.

	// trajectory parameters
	set gt0 to 200.
	set gt1 to 40000.//48
	// velocity parameters
	set maxq to 7000.
//	set maxq to 9000.

}

//minmus 5.9
set incl to 0.

set tset to 1.
lock throttle to tset. 
set pitch to 0.

FUNCTION eng_out {

	local numOut to 0.
	LIST ENGINES IN eng_list.
	FOR eng IN eng_list
		IF eng:FLAMEOUT
			SET numOut TO numOut + 1.
	return numOut.
}

lock angle1 to arcsin(max(-1,min(1,cos(180+incl)/cos(ship:latitude)))).
lock vlaunchx to (1600 * sin(angle1*-1))-(174.9422*sin(90)). 
lock vlaunchy to (1600 * cos(angle1*-1))-(174.9422*cos(90)). 
lock newangle to 90-arctan(vlaunchx/vlaunchy).
lock steering to HEADING(arcsin(max(-1,min(1,cos(180+newangle)/cos(ship:latitude)))), 90-pitch ) + R(0,0,-180)+ correctRoll.
//lock steering to lookdirup( HEADING(arcsin(max(-1,min(1,cos(180+newangle)/max(0.001,cos(ship:latitude))))), 90-pitch ):vector, ship:facing:topvector).
//lock steering to up + r(0,pitch,0) + correctRoll.

log "L:"+ship:longitude+" "+time:seconds to "log1.txt".

if not((eng_out() = 0)) or (maxthrust=0) {
	logev("Ignition (incl:"+incl+")"). 
	stage.
}
set arramp to radar_alt + 25.

when radar_alt > arramp or not (prog_mode = 1) then {
	gear off.
	SET WARP TO 2.
	if not ( prog_mode = 1) {return false.}
	logev("tower clear.").
}

when radar_alt > gt0 or not (prog_mode = 1) then {
//	SET WARP TO 4.
	if not ( prog_mode = 1) {return false.}
	logev(" begin turn."). 
	lock pitch to max(-90,min(-angle,(((radar_alt+50)-gt0)*19.9/body:atm:height)^0.55*-23)).

	when radar_alt > gt1 or altitude > ha or apoapsis > lorb or not (prog_mode = 1) then {
		if not ( prog_mode = 1) {return false.}
		logev(round(missiontime) + " end turn."). 
		set pitch to -90.
	}

}
	
when not((eng_out() = 0)) or ( not ( prog_mode = 1)) then {
	if not(prog_mode = 1) return false.
			
	if not((eng_out() = 0)) {
		logev("stage out:"+eng_out()).
		stage.
	}
	return true.
}
	
//on round(time:seconds,1) {
//
//	if (altitude > vac) or not (prog_mode = 1) {
//		return false.
//	}
//	
//	local angle to VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR).
//
//	log round(missiontime,2)+" "+round(radar_alt,2)+" "+round(altitude,2)+" "+round(velocity:surface:mag,2)+" " to "launchlog.txt".
//	log round(missiontime,2)+" "+round(pitch*-1,2)+" "+round(angle,2) to "pitchlog.txt".
//
//	return true.
//}

on round(time:seconds,1) {
	
	if not ( prog_mode = 1) {return false.}

	if altitude > ha or apoapsis > lorb {
		return false.
	}
	
	// dynamic pressure q
	set vsm to velocity:surface:mag.
	set exp to -altitude/5000.
	set ad to 1.2230948554874 * 2.718281828^exp.    // atmospheric density
	set q to 0.5 * ad * vsm^2.
	// calculate target velocity
	set vl to maxq*0.9.
	set vh to maxq*1.1.
	if q < vl { set tset to 1. }
	if q > vl and q < vh { set tset to (vh-q)/(vh-vl). }
	if q > vh { set tset to 0.35. }
	
	if altitude < 10000 and tset < 0.8 { set tset to 0.8. }
	
	if abs(STEERINGMANAGER:ANGLEERROR) > 1 {set tset_a to tset. lock tset to tset_a+abs(STEERINGMANAGER:ANGLEERROR)/30. }
	if tset < 0.25 { set tset to 0.35. } //only in lower atmo

	if ship:velocity:surface:mag < 350 { set tset to 1. }

	print "pitch: " + round(pitch,2) + "  " at (0,25).
	print "alt:radar: " + round(radar_alt) + "  " at (0,26). 
	print "q: " + round(q) + "  " at (0,27). 
	print "throttle: " + round(tset,2) + "   " at (0,28).
	print "apoapis: " + round(apoapsis/1000,2) at (0,29).
	print "periapis: " + round(periapsis/1000,2) at (0,30).
	
	
	return true.
}
	
when altitude > 10000 or not (prog_mode = 1) then {
	
	if not ( prog_mode = 1) {return false.}
		
	//lock steering to lookdirup( HEADING(arcsin(max(-1,min(1,cos(180+newangle)/max(0.001,cos(ship:latitude))))), 90 ):vector, ship:prograde:vector).
	lock steering to lookdirup(ship:srfprograde:vector, ship:facing:topvector).
}

when altitude > 16000 or not (prog_mode = 1) then {
	
	if not ( prog_mode = 1) {return false.}
		
	set maxq to 7000.
}

when altitude > 53000 or not (prog_mode = 1) then {
	
	if not ( prog_mode = 1) {return false.}
		
	run las_jet.

	logev("fairing deploy").
	FOR mypart IN SHIP:PARTS {
		if not(mypart:tag = "INH") and mypart:allmodules:contains("ModuleProceduralFairing") {
			local mymod to mypart:getmodule("ModuleProceduralFairing").
			if mymod:hasevent("deploy") {
				logev("deploy "+mypart:title+" "+mypart:stage).
				mymod:doevent("deploy").
			}
		}
	}
}

when (altitude > ha or apoapsis > lorb) or not (prog_mode = 1) then {

	if not ( prog_mode = 1) {return false.}
	
	logev("stage2-part").
	set tset to 0.

	if altitude < vac {

		logev("Waiting to leave atmosphere").

		lock steering to lookdirup(ship:prograde:vector, ship:facing:topvector).
		
		on round(time:seconds,1) {
		
			if (altitude > vac) or not (prog_mode = 1) {
				return false.
			}

			if apoapsis < lorb { set tset to (lorb-apoapsis)/(lorb*0.01). }
			else 
			{ 
				set tset to 0. 
			}
			set vsm to velocity:surface:mag.
			set exp to -altitude/5000.
			set ad to 1.2230948554874 * 2.718281828^exp.    // atmospheric density
			set q to 0.5 * ad * vsm^2.
			print "pitch: " + round(pitch,2) + "  " at (0,25).
			print "alt:radar: " + round(radar_alt) + "  " at (0,26). 
			print "q: " + round(q) + "  " at (0,27). 
			print "throttle: " + round(tset,2) + "   " at (0,28).
			print "apoapis: " + round(apoapsis/1000,2) at (0,29).
			print "periapis: " + round(periapsis/1000,2) at (0,30).

			return true.
		}
	}
}

when (altitude > vac) or not ( prog_mode = 1) then {

	if not ( prog_mode = 1) {return false.}
	
	logev("stage3-part").
	
	unlock steering.
	SET WARP TO 0.
	set tset to 0.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	unlock throttle.

	rcs on.
	run deploy.
	run aponode(lorb).
	run exenode.


}

