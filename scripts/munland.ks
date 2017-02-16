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
do_partmodule_event("LM_DESC","ModuleEnginesFX","activate engine").
set targetlong to -12.75.


set pretarget to targetlong+12.6856. //number bigger: correct to east
set diff to pretarget+10.


SET thrott TO 0.
LOCK THROTTLE TO thrott.

run h.
//lock veh_h to ((h_ - facing:forevector):mag)+1.21.
lock stopat to 5.5.
lock alt_radar to ship:altitude-max(0,ship:GEOPOSITION:TERRAINHEIGHT).

unlock steering.
sas on.
set kuniverse:timewarp:mode to "RAILS".
set warp to 4.
print ship:longitude.
wait until ship:longitude > diff. 
print ship:longitude.
wait until ship:longitude < diff.
print diff+" "+ship:longitude.
set warp to 0.
sas off.
lock steering to lookdirup(ship:retrograde:vector, ship:facing:topvector).
wait until VECTORANGLE(ship:retrograde:vector,SHIP:FACING:VECTOR) < 1.
unlock steeting.
sas on.
set kuniverse:timewarp:mode to "PHYSICS".
set warp to 2.
wait until ship:longitude < pretarget.
print pretarget+" "+ship:longitude.
sas off.
lock steering to lookdirup(ship:retrograde:vector, ship:facing:topvector).


SET Kp TO 0.6.
SET Ki TO 0.00.
SET Kd TO 0.00.
SET PID TO PIDLOOP(Kp, Ki, Kd).
SET PID:SETPOINT TO stopat.
SET PID:maxoutput TO 1.
SET PID:minoutput TO 0.


set x_grav to body:mu/((body:radius+SHIP:GEOPOSITION:TERRAINHEIGHT)^2).
print ship:longitude.
print "- steer RG (for burn)".

wait until VECTORANGLE(ship:retrograde:vector,SHIP:FACING:VECTOR) < 5.
set burnvector to lookdirup(ship:retrograde:vector, ship:facing:topvector).
lock steering to burnvector.
	
print "- fire".
set thrott to 1.

wait until ship:velocity:orbit:mag < 250.

set kuniverse:timewarp:mode to "PHYSICS".
set kuniverse:timewarp:warp to 3.

set thrott to 0.

print "- deorbit done".

lock steering to lookdirup(ship:srfretrograde:vector, ship:facing:topvector).
	
when alt_radar < 2000 then {
	set kuniverse:timewarp:warp to 2.
	when alt_radar < 1000 then {
		set kuniverse:timewarp:warp to 1.
		when alt_radar < 200 then {
			set kuniverse:timewarp:warp to 0.
		}
	}
}

UNTIL ship:verticalspeed >= -0.1 {

	set ssb_alt2 to 1.1* ((2 * x_grav * (max(0,alt_radar-stopat))) + ship:verticalspeed^2) / (2.0 * ((maxthrust*sin(90-min(60,VECTORANGLE(SHIP:UP:VECTOR,SHIP:facing:VECTOR))))/ship:mass)).	
	//set ssb_alt2 to 1.1* ((2 * x_grav * (max(0,alt_radar-stopat))) + ship:verticalspeed^2) / (2.0 * (maxthrust/ship:mass)).	
	//print "ssb_alt2:"+ssb_alt2.
	//print "SP:"+(alt_radar-ssb_alt2).

	set thrott TO PID:UPDATE(TIME:SECONDS,alt_radar-ssb_alt2).// / sin(90-VECTORANGLE(SHIP:UP:VECTOR,SHIP:facing:VECTOR)).

	if alt_radar < stopat+ssb_alt2 {
	//	set thrott to 1.
	}
	if thrott = 1 and alt_radar > stopat+ssb_alt2 {
	//	set thrott to 0.6.
	}
	

	WAIT 0.001.
}
print ship:longitude.
unlock throttle.
unlock steering.
sas on.

wait 2.
sas off.
