// launch to orbit (w/ atmosphere)

if body:name = "Kerbin" {

	set lorb to 80000.
	set ha to 59000.
	set vac to 70000.

	set angle to 14.

	// trajectory parameters
	set gt0 to 60.
	set gt1 to 45000.//48
	// velocity parameters
	set maxq to 6000.
//	set maxq to 9000.

}

set tset to 1.
lock throttle to tset. 
set pitch to 0.
lock steering to up + r(0,pitch,0) + correctRoll.

print "T-0  All systems GO. Ignition!". 
set arramp to radar_alt + 25.

when radar_alt > arramp or not (prog_mode = 1) then {
	SET WARP TO 3.
	if not ( prog_mode = 1) {return false.}
	print "T+" + round(missiontime) + " tower clear.".
}

when radar_alt > gt0 or not (prog_mode = 1) then {
//	SET WARP TO 4.
	if not ( prog_mode = 1) {return false.}
	print "T+" + round(missiontime) + " begin turn.". 
	lock pitch to max(-90,min(-angle,(altitude*19.9/body:atm:height)^0.55*-23)).

	when radar_alt > gt1 or altitude > ha or apoapsis > lorb or not (prog_mode = 1) then {
		if not ( prog_mode = 1) {return false.}
		print "T+" + round(missiontime) + " end turn.". 
		set pitch to -90.
	}

}
	
on round(time:seconds,1) {

	if (altitude > vac) or not (prog_mode = 1) {
		return false.
	}
	
	local angle to VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR).

	log round(missiontime,2)+" "+round(radar_alt,2)+" "+round(altitude,2)+" "+round(velocity:surface:mag,2)+" " to "launchlog.txt".
	log round(missiontime,2)+" "+round(pitch*-1,2)+" "+round(angle,2) to "pitchlog.txt".

	return true.
}
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
	if q > vh { set tset to 0.25. }
	
	if abs(STEERINGMANAGER:ANGLEERROR) > 1 {set tset to tset*abs(STEERINGMANAGER:ANGLEERROR). }
	if tset < 0.25 { set tset to 0.25. } //only in lower atmo

	if ship:velocity:surface:mag < 520 { set tset to 1. }

	print "pitch: " + round(pitch,2) + "  " at (0,25).
	print "alt:radar: " + round(radar_alt) + "  " at (0,26). 
	print "q: " + round(q) + "  " at (0,27). 
	print "throttle: " + round(tset,2) + "   " at (0,28).
	print "apoapis: " + round(apoapsis/1000,2) at (0,29).
	print "periapis: " + round(periapsis/1000,2) at (0,30).
	if maxthrust = 0 {
		stage.
	}
	return true.
}

when altitude > 26000 or not (prog_mode = 1) then {
	
	if not ( prog_mode = 1) {return false.}
		
	LOCK STEERING TO SHIP:PROGRADE. 

}

when altitude > 53000 or not (prog_mode = 1) then {
	
	if not ( prog_mode = 1) {return false.}

	print "fairing deploy".
	FOR mypart IN SHIP:PARTS {
		if mypart:allmodules:contains("ModuleProceduralFairing") {
			local mymod to mypart:getmodule("ModuleProceduralFairing").
			if mymod:hasevent("deploy") {
				print "deploy "+mypart:title+" "+mypart:stage.
				mymod:doevent("deploy").
			}
		}
	}
}

when (altitude > ha or apoapsis > lorb) or not (prog_mode = 1) then {

	if not ( prog_mode = 1) {return false.}
	
	print "stage2-part".
	set tset to 0.

	if altitude < vac {

		print "T+" + round(missiontime) + " Waiting to leave atmosphere".
		
		LOCK STEERING TO SHIP:PROGRADE. 
		
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
	
	print "stage3-part".
	
	unlock steering.
	SET WARP TO 0.
	set tset to 0.
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	unlock throttle.
	
	run deploy.
	run aponode(lorb).
	run exenode.


}

