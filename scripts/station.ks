global station_mode to "hold".
sas off.
lock steering to ship:prograde.

set cpupart to ship:partsdubbed("AGC_STATION")[0].

lock ctrlface to ship:controlpart:facing:forevector - cpupart:facing:forevector.

function station_toggle {

	logev(ctrlface).

	if station_mode = "hold" 
	{
		SET SHIP:CONTROL:NEUTRALIZE to TRUE.
		unlock steering.
		sas on.
		set station_mode to "free".
	} else {
		sas off.
		lock steering to ship:prograde.
		//:forevector + ctrlface.
		set station_mode to "hold".
	}

	logev(station_mode).
}


function station_gui
{
}

