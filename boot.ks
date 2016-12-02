CLEARSCREEN.
PRINT "boot".
SET CONFIG:TELNET TO TRUE.
PRINT "telnet: ok".
SWITCH TO 0.


wait until ship:loaded.

wait 2.


ON AG1 {

	PRINT "ag1 - las sep".

	run las_sep.
	
}

ON AG2 {

	PRINT "ag2 - deploy".

	run deploy.
	
}

ON AG9 {

	PRINT "ag9 - deorbit".

	run deorbit.
	
}

ON AG0 {

	preserve.

	PRINT "ag0 - abort".

	run abort.
	
}


WAIT UNTIL FALSE.
