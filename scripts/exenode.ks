// execute maneuver node

set prog_mode to 4.

print "T+" + round(missiontime) + " Node apoapsis: " + round(NEXTNODE:orbit:apoapsis/1000,2) + "km, periapsis: " + round(NEXTNODE:orbit:periapsis/1000,2) + "km".
print "T+" + round(missiontime) + " Node in: " + round(NEXTNODE:eta) + ", DeltaV: " + round(NEXTNODE:deltav:mag).
set maxa to maxthrust/mass.
set dob to NEXTNODE:deltav:mag/maxa.     // incorrect: should use tsiolkovsky formula
print "T+" + round(missiontime) + " Max acc: " + round(maxa) + "m/s^2, Burn duration: " + round(dob) + "s".
sas off.


//function burntime {
//parameter deltav.
//set res to engine_isp_thrust_sum().
//set ve to g_isp * 9.8.
//return ((mass*ve)/g_maxthr)*(1-constant:e^(-deltav/ve)).
//}

FUNCTION calcAverage {
	PARAMETER inputList.
	LOCAL sum IS 0.
	FOR val IN inputList {
		SET sum TO sum + val.
	}.
	RETURN sum / inputList:LENGTH.
}.

global avglist to list().
	
lock steering to lookdirup(nextnode:deltav, ship:facing:topvector).

avglist:clear().

local burn_done to 0.

when (avglist:length > 10 and calcAverage(avglist) < 0.4) or ( not ( prog_mode = 4))  then {

	unlock steering.
	if not(prog_mode = 4) {
		return false.
	}

	print "aligned for warp".
		
	SET SASMODE TO "STABILITY".
	sas on.
	
	run warpfor(NEXTNODE:eta - dob/2 - 2).

	when warping = 0 then {

		sas off.
		if not(prog_mode = 4) {
			return false.
		}
		lock steering to lookdirup(nextnode:deltav, ship:facing:topvector).
		avglist:clear().

		when (avglist:length > 10 and calcAverage(avglist) < 1.5) or ( not ( prog_mode = 4))  then {

			if not(prog_mode = 4) {
				unlock steering.
				return false.
			}

			print "aligned for burn".
			
			when ((nextnode:eta - dob/2) < 1) or ( not ( prog_mode = 4)) then {
				
				if not(prog_mode = 4) {
					unlock steering.
					return false.
				}
				
				print "burn".

				lock throttle to (nextnode:burnvector:mag*mass)/(maxthrust+0.01).

				when (nextnode:burnvector:mag < 3) or ( not ( prog_mode = 4)) then {
					
					if not(prog_mode = 4) {
						return false.
					}
					print "fix steer".
					set np to lookdirup(nextnode:deltav, ship:facing:topvector).
					lock steering to np.
				}
				
				
				when (nextnode:burnvector:mag < .05) or ( not ( prog_mode = 4)) then {

					unlock throttle.
					unlock steering.

					if not(prog_mode = 4) {
						return false.
					}

					set prog_mode to 0.
					set burn_done to 1.
				}
			}
		}
	}
}

on round(time:seconds,1) {

	if not (prog_mode = 4) {
		if burn_done = 1 {
			print "T+" + round(missiontime) + " Apoapsis: " + round(apoapsis/1000,2) + "km, periapsis: " + round(periapsis/1000,2) + "km".
			print "T+" + round(missiontime) + " Fuel after burn: " + round(stage:liquidfuel).
			remove nextnode.
			sas on.
			set sasmode to "STABILITY".
		}
		return false.
	}
	
	//if not(throttle = 0) and maxthrust = 0 {
	//	stage.
	//}

	avglist:add(VECTORANGLE(nextnode:deltav,SHIP:FACING:VECTOR)).
	if avglist:length > 12 { avglist:remove(0).}
	
	return true.
}

