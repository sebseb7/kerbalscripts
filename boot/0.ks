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
	
	preserve.

	PRINT "ag9 - deorbit".

	run deorbit.
	
}

ON AG10 {

	preserve.

	PRINT "ag10 - abort".

	run abort.
	
}

ON Abort {

	preserve.

	PRINT "abort - abort".

	run abort.
	
}


WAIT UNTIL FALSE.
