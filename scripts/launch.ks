// launch to orbit (w/ atmosphere)

if body:name = "Kerbin" {

	set lorb to 80000.
	set ha to 59000.
	set vac to 70000.

//	set angle to 7. //twr 1.4
//	set angle to 7. //twr 1.4
//	set angle to 9.5. //twr 1.8
	set angle to 5.6. // twr 2.0
//	set angle to 6.1. // twr 2.1
//	set angle to 6.8. // twr 2.2
//	set angle to 8.5. // twr 2.2
//	set angle to 9.5. // twr 2.2
//	set angle to 17. // twr 3
	set maxq to 15000.

}



FUNCTION eng_out {

	local numOut to 0.
	LIST ENGINES IN eng_list.
	FOR eng IN eng_list
		IF eng:FLAMEOUT
			SET numOut TO numOut + 1.
	return numOut.
}

set tset to 1.
lock throttle to tset. 

//minmus 5.9
set incl to 0.
set pitch to 0.
lock angle1 to arcsin(max(-1,min(1,cos(180+incl)/cos(ship:latitude)))).
lock vlaunchx to (1600 * sin(angle1*-1))-(174.9422*sin(90)). 
lock vlaunchy to (1600 * cos(angle1*-1))-(174.9422*cos(90)). 
lock newangle to 90-arctan(vlaunchx/vlaunchy).
lock steering to HEADING(arcsin(max(-1,min(1,cos(180+newangle)/cos(ship:latitude)))), 90-pitch ) + R(0,0,-180)+ correctRoll.
//lock steering to lookdirup( HEADING(arcsin(max(-1,min(1,cos(180+newangle)/max(0.001,cos(ship:latitude))))), 90-pitch ):vector, ship:facing:topvector).
clearscreen.
log "L:"+ship:longitude+" "+time:seconds to "log1.txt".

if not((eng_out() = 0)) or (maxthrust=0) {
	logev("Ignition (incl:"+incl+")"). 
	stage.
}
set arramp to radar_alt + 25.

when radar_alt > arramp or not (prog_mode = 1) then {
	gear off.
	SET WARP TO 1.
	if not ( prog_mode = 1) {return false.}
	logev("tower clear.").
}

when ship:velocity:surface:mag > 20 or not (prog_mode = 1) then {
	
	if not ( prog_mode = 1) {return false.}
	lock pitch to -1*(VECTORANGLE(SHIP:UP:VECTOR,SHIP:srfprograde:VECTOR)+5).

	logev("begin turn: "+angle).

	when abs( VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR)) > angle or not (prog_mode = 1) then {
		if not ( prog_mode = 1) {return false.}
		logev("follow srfpg").
		SET WARP TO 2.
		lock steering to lookdirup(ship:srfprograde:vector, ship:facing:topvector).
	
		when altitude > ha or apoapsis > lorb or not (prog_mode = 1) then {
			if not ( prog_mode = 1) {return false.}
			logev(round(missiontime) + "end turn."). 
			lock steering to lookdirup(ship:prograde:vector, ship:facing:topvector).
		}
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
	
on round(time:seconds,1) {
	
	if altitude > ha or apoapsis > lorb or not (prog_mode = 1) {
		set tset to 0.
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
	
	if altitude < 10000 and tset < 0.5 { set tset to 0.5. }
	
	if abs(STEERINGMANAGER:ANGLEERROR) > 1 {set tset_a to tset. lock tset to tset_a+abs(STEERINGMANAGER:ANGLEERROR)/30. }
	if tset < 0.25 { set tset to 0.25. } //only in lower atmo

	if ship:velocity:surface:mag < 350 { set tset to 1. }

	print "pitch: " + round(pitch,2) + "  " at (0,25).
	print "alt:radar: " + round(radar_alt) + "  " at (0,26). 
	print "q: " + round(q) + "  " at (0,27). 
	print "throttle: " + round(tset,2) + "   " at (0,28).
	print "apoapis: " + round(apoapsis/1000,2) at (0,29).
	print "periapis: " + round(periapsis/1000,2) at (0,30).
	
	
	return true.
}
	
when altitude > 48000 or not (prog_mode = 1) then {
	
	if not ( prog_mode = 1) {return false.}
		
	run las_jet.

}

when altitude > 53000 or not (prog_mode = 1) then {
	
	if not ( prog_mode = 1) {return false.}
		
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
	
//	SET WARP TO 3.
	
	logev("stage2-part").
	set tset to 0.

	if altitude < vac {

		logev("Waiting to leave atmosphere").
//		SET WARP TO 3.

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
	set prog_mode to 4.
	run exenode.


}

