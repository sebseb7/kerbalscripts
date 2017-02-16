function do_partmodule_event {
	parameter part_name.
	parameter module_name.
	parameter event_name.

	for parapart IN SHIP:PARTSDUBBED(part_name)  {
		if parapart:allmodules:contains(module_name) {
			if parapart:getmodule(module_name):hasevent(event_name) {
				parapart:getmodule(module_name):DOEVENT(event_name).
			}
		}
	}
}
do_partmodule_event("LM_ASC","ModuleEnginesFX","activate engine").
do_partmodule_event("LMSEP","ModuleDecouple","decouple").

// launch to orbit in vacuum (no atmosphere)
set rb to 200000.//mun
set mu to 6.5138398*10^10.
set lorb to 14000.


set ov to sqrt(mu/rb).           // orbital velocity for circular orbit
print "Mission start at: " + time:calendar + ", " + time:clock.
print "Orbit v: " + round(ov) + " for low " + body:name + " orbit in " + round(lorb/1000) + "km".
print "T+" + round(missiontime) + " All systems GO!".
wait 0.1.
print "T+" + round(missiontime) + " Ignition.".

sas off.

wait 0.1.

//lauch 9deg phase angle


set pitch to 0.
//set incl to 0.099.
set incl to 178.833.
//print target:orbit:inclination.
//set incl to target:orbit:inclination.
lock angle1 to arcsin(max(-1,min(1,cos(180+incl)/cos(ship:latitude)))).
lock vlaunchx to (570 * sin(angle1*-1))-(9.0416*sin(90)). 
lock vlaunchy to (570 * cos(angle1*-1))-(9.0416*cos(90)). 
lock newangle to 90-arctan(vlaunchx/vlaunchy).
//lock steering to HEADING(arcsin(max(-1,min(1,cos(180+newangle)/max(0.001,cos(ship:latitude))))), 90-pitch ) + R(0,0,-180).
lock steering to lookdirup( HEADING(arcsin(max(-1,min(1,cos(180+newangle)/max(0.001,cos(ship:latitude))))), 90-pitch ):vector, ship:facing:topvector).

//lock steering to up + R(0, 0, 90).
// takeoff thrust
set r to rb + altitude.
set ag to mu/r^2.          // gravitational accelaration
set ta to maxthrust/mass.  // thrust accelaration
lock throttle to 1.
wait until ship:velocity:surface:mag > 20.
print "T+" + round(missiontime) + " Orbital orientation turn".
// control speed and attitude
set ot to round(missiontime).
until apoapsis > lorb {
    set ar to alt:radar.
    set vsm to velocity:surface:mag.
    // control attitude
    set r to rb + altitude.
    set ag to mu/r^2.          // gravitational accelaration
    set vt2 to velocity:orbit:mag^2 - verticalspeed^2. // tangential velocity
    set ac to vt2/r.           // centrifugal accelaration
    set avert to ag - ac.      // vertical external acceleration
    set ta to maxthrust/mass.  // thrust accelaration
    set pitch to arccos(avert/ta)*-1.
    // dashboard
    print "alt:radar: " + round(ar) + "  " at (0,32).
    print "altitude: " + round(altitude) + "  " at (20,32).
    print "v:orbit: " + round(velocity:orbit:mag) + "  " at (0,33).
    print "vt: " + round(sqrt(vt2)) + "  " at (20,33).
    print "pitch: " + round(pitch) + "  " at (0,34).
    print "apoapis: " + round(apoapsis/1000,1) + "  " at (0,35).
    print "periapis: " + round(periapsis/1000,1) + "  " at (20,35).
    wait 0.1.
}
lock throttle to 0.
print "T+" + round(missiontime) + " Apoapsis at " + round(apoapsis/1000,2) + "km".
unlock steering.


wait 1.
run aponode(lorb).

//set np to up + R(0, -yaw, 0).
//wait until abs(sin(np:pitch) - sin(facing:pitch)) < 0.02 and abs(sin(np:yaw) - sin(facing:yaw)) < 0.02 and abs(sin(np:roll) - sin(facing:roll)) < 0.02.
//wait 1.                 // BUG: without this wait aponode calculations are incorrect!
//run aponode(apoapsis).
//run exenode.
