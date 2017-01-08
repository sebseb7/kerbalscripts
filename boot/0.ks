wait until ship:unpacked.
CLEARSCREEN.
PRINT "boot "+core:tag.
SET CONFIG:STAT TO TRUE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SET CONFIG:TELNET TO TRUE.
PRINT "telnet: ok".
//SWITCH TO 0.
//PRINT "archive: ok".
if homeconnection:isconnected {
	if not (open("0:/boot/0.ks"):readall:string = open("/boot/0.ks"):readall:string ) {
		print "updateting boot and reboot".
		copypath("0:/boot/0.ks","/boot/0.ks").
		reboot.
	}
	
	copypath("0:/scripts","/").
	PRINT "copy: ok".

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

	local ag1_o to ag1.
	local ag2_o to ag2.
	local ag3_o to ag3.
	local ag4_o to ag4.
	local ag5_o to ag5.
	local ag6_o to ag6.
	local ag8_o to ag8.
	local ag9_o to ag9.
	local ag10_o to ag10.
	local abort_o to abort.
	local seconds_o to sessiontime.

	when true then {

		if seconds_o+0.25 > sessiontime return true.
	
		if ship:electriccharge < 10 return false.

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
			preserve.
			logev("ag4").
			run ag4.
		}

		if not(ag5_o=ag5) {
			preserve.
			logev("ag5").
			run ag5.
		}

		if not(ag6_o=ag6) {
			preserve.
			logev("ag6 - up").
			run ag6_up.
		}

		if not(ag8_o=ag8) {
			preserve.
			logev("ag8 - right").
			run ag8_right.
		}

		if not(ag9_o=ag9) {
			preserve.
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
		set seconds_o to sessiontime.
	
		return true.

	}
	logev("ready").

	WAIT UNTIL FALSE.
}

