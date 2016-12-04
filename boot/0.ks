CLEARSCREEN.
PRINT "boot AGC".
SET CONFIG:TELNET TO TRUE.
PRINT "telnet: ok".
SWITCH TO 0.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

run globals.

wait until ship:loaded.
wait until stage:ready.

wait 1.

print "ready".

ON AG1 {
	PRINT "ag1 - launch".
	set prog_mode to 1.
	run launch.
}

ON AG2 {
	PRINT "ag2 - las sep".
	run las_jet.
}

ON AG3 {
	PRINT "ag3 - deploy".
	run deploy.
}

ON AG4 {
	preserve.
	PRINT "ag4".
	run ag4.
}

ON AG5 {
	preserve.
	PRINT "ag5".
	run ag5.
}

ON AG6 {
	preserve.
	print "ag6 - up".
	run ag6_up.
}

ON AG7 {
	preserve.
	print "ag7 - down".
	run ag7_down.
}

ON AG8 {
	preserve.
	print "ag8 - right".
	run ag8_right.
}

ON AG9 {
	preserve.
	print "ag9 - left".
	run ag9_left.
}

ON AG10 {
	PRINT "ag10 - deorbit".
	set prog_mode to 10.
	run deorbit.
}

ON Abort {
	PRINT "abort - abort".
	set prog_mode to 11.
	run abort.
}


WAIT UNTIL FALSE.
