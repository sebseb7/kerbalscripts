// launch to orbit (w/ atmosphere)

if body:name = "Kerbin" {

	set lorb to 80000.
	set ha to 59000.

	// trajectory parameters
	set gt0a to 210.
	set gt0 to -5000.
//	set gt0 to -15000.
	set gt1 to 50000.
//	set gt1 to 48000.
	set gtx0 to 600.
	set gtx1 to 3300.
	set pitch0 to 0.
	set pitch1 to 90.
	// velocity parameters
	set maxq to 19500.

}

set tset to 1.
lock throttle to tset. 
lock steering to up + correctRoll.

print "T-0  All systems GO. Ignition!". 
set arramp to radar_alt + 25.

when radar_alt > arramp then {
	SET WARP TO 3.
	print "T+" + round(missiontime) + " tower clear.".
}

when radar_alt > gt0a then {
	SET WARP TO 4.
	print "T+" + round(missiontime) + " Beginning gravity turn.". 
}

set pitch to 0.

on round(time:seconds,1) {
	
	if not ( prog_mode = 1) {
		print "launch abort detected".
		return false.
	}

	if altitude > ha or apoapsis > lorb {
		return false.
	}
	set ar to radar_alt.
	// control attitude
	if ar > gt0a and ar < gt1 {
		//set warp to 4.
		set arr to (ar - gt0) / (gt1 - gt0).
		set pda to (cos(arr * 180) + 1) / 2.
		set pitch to min(-5.1,pitch1 * ( pda - 1 )).
		//set pitch to pitch1 * ( pda - 1 ).
		if ar > gtx0 and ar < gtx1 
		{
			LOCK STEERING TO SHIP:VELOCITY:SURFACE:DIRECTION + correctRoll. 
			print "pitch: " + round(pitch,2) + "P " at (20,33).
		}else{
			lock steering to up + R(0, pitch,0)+ correctRoll.
			print "pitch: " + round(pitch,2) + "  " at (20,33).
		}
	}
	if ar > gt1 {
		lock steering to up + R(0, pitch, 0)+correctRoll.
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
	if tset < 0.4 { set tset to 0.4. } //only in lower atmo
	if q > vh { set tset to 0.4. }
	print "alt:radar: " + round(ar) + "  " at (0,33). 
	print "q: " + round(q) + "  " at (20,34). 
	print "throttle: " + round(tset,2) + "   " at (0,34).
	print "apoapis: " + round(apoapsis/1000) at (0,35).
	print "periapis: " + round(periapsis/1000) at (20,35).
	if maxthrust = 0 {
		stage.
	}
	return true.
}


when (altitude > ha or apoapsis > lorb) or not (prog_mode = 1) then {

	if not ( prog_mode = 1) {
		print "launch abort detected".
		return false.
	}

	print "stage2-part".
	set tset to 0.

	if altitude < ha {

		print "T+" + round(missiontime) + " Waiting to leave atmosphere".
		lock steering to up + R(0, pitch, 0)+correctRoll.  
		
		on round(time:seconds,1) {
		
			if altitude > ha {
				return false.
			}

			if apoapsis < lorb { set tset to (lorb-apoapsis)/(lorb*0.01). }
			else 
			{ 
				set tset to 0. 
			}
			print "apoapis: " + round(apoapsis/1000,2) at (0,32).
			print "periapis: " + round(periapsis/1000,2) at (20,32).

			return true.
		}
	}
}

when (altitude > ha) or not ( prog_mode = 1) then {

	if not ( prog_mode = 1) {
		print "launch abort detected".
		return false.
	}
	print "stage3-part".
	
	unlock steering.
	SET WARP TO 0.
	set tset to 0.
	lock throttle to 0.
	run aponode(lorb).
	
	SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
	unlock throttle.
	
}

