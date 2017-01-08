// execute maneuver node

set prog_mode to 4.

set maxa to maxthrust/mass.
//set dob to NEXTNODE:deltav:mag/maxa.     // incorrect: should use tsiolkovsky formula
local g_isp is 0.
local g_maxthr is 0.
list engines in eng_list.
local m is 0.
local t is 0.
for e in eng_list
	if e:ignition {
		local th is e:maxthrust*e:thrustlimit/100.
		set t to t + th.
		if e:visp = 0
			set m to 1.
		else
			set m to m+th/e:visp.
	}
if not(m = 0) {
	set g_isp to t/m.
	set g_maxthr to t.
}

if g_maxthr = 0 {
	GETVOICE(0):PLAY(NOTE(400,0.2)).
	set prog_mode to 0.
	print "no active engine".
}

when altitude > 53000 or not (prog_mode = 4) then {
	
	if not ( prog_mode = 4) {return false.}

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
	
FUNCTION eng_out {

	local numOut to 0.
	LIST ENGINES IN eng_list.
	FOR eng IN eng_list
		IF eng:FLAMEOUT
			SET numOut TO numOut + 1.
	return numOut.
}

FUNCTION calcAverage {
	PARAMETER inputList.
	LOCAL sum IS 0.
	FOR val IN inputList {
		SET sum TO sum + val.
	}.
	RETURN sum / inputList:LENGTH.
}.

if prog_mode = 4 {

	set ve to g_isp * 9.8.
	set dob to ((mass*ve)/g_maxthr)*(1-constant:e^(-nextnode:deltav:mag/ve)).

	print "T+" + round(missiontime) + " Node apoapsis: " + round(NEXTNODE:orbit:apoapsis/1000,2) + "km, periapsis: " + round(NEXTNODE:orbit:periapsis/1000,2) + "km".
	print "T+" + round(missiontime) + " Node in: " + round(NEXTNODE:eta) + ", DeltaV: " + round(NEXTNODE:deltav:mag).
	print "T+" + round(missiontime) + " Max acc: " + round(maxa) + "m/s^2, Burn duration: " + round(dob,2) + "s".
	sas off.


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
	
		run warpfor(NEXTNODE:eta - dob/2 - 4).

		when warping = 0 then {

			sas off.
			if not(prog_mode = 4) {
				return false.
			}
		
			lock steering to lookdirup(nextnode:deltav, ship:facing:topvector).
				
			avglist:clear().

			when (avglist:length > 10 and calcAverage(avglist) < 3.5) or ( not ( prog_mode = 4))  then {

				if not(prog_mode = 4) {
					unlock steering.
					return false.
				}

				print "aligned for burn".
			
				when ((nextnode:eta - dob/2) < (dob/50)) or ( not ( prog_mode = 4)) then {
				
					print (nextnode:eta - dob/2).

					if not(prog_mode = 4) {
						unlock steering.
						return false.
					}
				
					print "burn".

					lock throttle to (nextnode:burnvector:mag*mass)/(maxthrust+0.01)*1.5.

					when not((eng_out() = 0)) or ( not ( prog_mode = 4)) then {
						if not(prog_mode = 4) return false.
			
						if not((eng_out() = 0)) {
							print eng_out().
							stage.
						}
					}

					when (VECTORANGLE(nextnode:deltav,ship:facing:vector) > 50) or (nextnode:burnvector:mag < .05) or ( not ( prog_mode = 4)) then {

						unlock throttle.
						unlock steering.

						if not(prog_mode = 4) return false.
					
						if nextnode:burnvector:mag > .05 {
							print "burn aborted early".
							set burn_done to 2.
						}else{
							set burn_done to 1.
						}

						set prog_mode to 0.
					}
				}
			}
		}
	}

	on round(time:seconds,1) {

		if not (prog_mode = 4) {
			print "T+" + round(missiontime) + " Apoapsis: " + round(apoapsis/1000,2) + "km, periapsis: " + round(periapsis/1000,2) + "km".
			print "T+" + round(missiontime) + " Fuel after burn: " + round(stage:liquidfuel).

			log "N:"+ship:longitude+" "+time:seconds to "log1.txt".
		
			if burn_done = 1 {
				remove nextnode.
				sas on.
				set sasmode to "STABILITY".
			}
			if burn_done = 2 {
				sas on.
				set sasmode to "STABILITY".
			}
			return false.
		}
	
		if not(throttle = 0) and maxthrust = 0 {
			stage.
		}

		avglist:add(VECTORANGLE(nextnode:deltav,SHIP:FACING:VECTOR)).
		if avglist:length > 12 { avglist:remove(0).}
	
		return true.
	}
}

