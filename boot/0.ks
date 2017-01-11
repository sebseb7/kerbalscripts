//@LAZYGLOBAL OFF.
wait until ship:unpacked.
CLEARSCREEN.
PRINT "boot "+core:tag.
SET CONFIG:IPU TO 550.
SET CONFIG:UCP TO FALSE.
SET CONFIG:STAT TO TRUE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SET CONFIG:TELNET TO TRUE.
PRINT "telnet: ok".

if homeconnection:isconnected {
	if not (open("0:/boot/0.ks"):readall:string = open("/boot/0.ks"):readall:string ) {
		print "updateting boot and reboot".
		copypath("0:/boot/0.ks","/boot/0.ks").
		wait 2.
		reboot.
	}
	
	for file in open("0:/scripts"):list:values {
	
		if file:isfile and ( not( EXISTS("/scripts/"+file:name) ) or ( not (file:readall:string = open("/scripts/"+file:name):readall:string )) ) {
			copypath("0:/scripts/"+file:name,"/scripts/"+file:name).
			PRINT "copy: "+file:name.
		}
	}

	for file in open("0:/scripts/tasks"):list:values {
	
		if file:isfile and ( not( EXISTS("/scripts/tasks/"+file:name) ) or ( not (file:readall:string = open("/scripts/tasks/"+file:name):readall:string )) ) {
			copypath("0:/scripts/tasks/"+file:name,"/scripts/tasks/"+file:name).
			PRINT "copy task: "+file:name.
		}
	}
	for file in open("/scripts/tasks"):list:values {
		
		if file:isfile and ( not( EXISTS("0:/scripts/tasks/"+file:name))) {
			PRINT "delete task: "+file:name.
			deletepath("/scripts/tasks/"+file:name).
		}

	}

} else {
	print "no copy".
}

cd("/scripts").


if core:tag = "DSKY" {
	
	run globals.
	
	logev("DSKY ready").

}

if core:tag = "AGC_STATION" {
	
	run globals.
	
	local ag7_o to ag7.
	local seconds_o to sessiontime.

	sas off.
	lock steering to prograde.

	when true then {

		if seconds_o+0.25 > sessiontime return true.
	
		if ship:electriccharge < 10 return false.
	
		if not(ag7_o=ag7) {
			preserve.
			logev("ag7 - agc sas"+sas).

			if sas = False {
				unlock steering.
				sas on.
			
			}else{
				sas off.
				lock steering to prograde.
			}

		}
		
		set ag7_o to ag7.
		set seconds_o to sessiontime.
	
		return true.

	}
	
	logev("station ready").

	WAIT UNTIL FALSE.
}

if core:tag = "AGC" {

	run globals.

	global ag1_o to ag1.
	global ag2_o to ag2.
	global ag3_o to ag3.
	global ag4_o to ag4.
	global ag5_o to ag5.
	global ag6_o to ag6.
	global ag8_o to ag8.
	global ag9_o to ag9.
	global ag10_o to ag10.
	global abort_o to abort.
	global seconds_o to sessiontime+0.25.

	logev("ready").

	until false {

		//if ship:electriccharge < 10 return false.

		if not(ag1_o=ag1) {
			logev("ag1 - launch").
			set prog_mode to 1.
			run launch.
		}

		if not(ag2_o=ag2) {
			logev("ag2 - las sep").
			run las_jet.
		}

		if not(ag3_o=ag3) {
			logev("ag3 - deploy").
			run deploy.
		}

		if not(ag4_o=ag4) {
			logev("ag4").
			run ag4.
		}

		if not(ag5_o=ag5) {
			logev("ag5").
			run ag5.
		}

		if not(ag6_o=ag6) {
			logev("ag6 - up").
			run ag6_up.
		}

		if not(ag8_o=ag8) {
			logev("ag8 - right").
			run ag8_right.
		}

		if not(ag9_o=ag9) {
			logev("ag9 - left").
			run ag9_left.
		}

		if not(ag10_o=ag10) {
			logev("ag10 - deorbit").
			set prog_mode to 10.
			run deorbit.
		}

		if not(abort_o=abort) {
			logev("abort - abort").
			set prog_mode to 11.
			run abort.
		}

		set ag1_o to ag1.
		set ag2_o to ag2.
		set ag3_o to ag3.
		set ag4_o to ag4.
		set ag5_o to ag5.
		set ag6_o to ag6.
		set ag8_o to ag8.
		set ag9_o to ag9.
		set ag10_o to ag10.
		set abort_o to abort.
		set seconds_o to sessiontime+0.25.
	
		wait 0.25.

	}

}

