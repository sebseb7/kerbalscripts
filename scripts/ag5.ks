on round(time:seconds,1) {

	local vsm to velocity:surface:mag.
	local exp to -altitude/5000.
	local ad to 1.2230948554874 * 2.718281828^exp.    // atmospheric density
	local q to 0.5 * ad * vsm^2.


	log round(time:seconds,2)+" "+round(ETA:APOAPSIS,2)+" "+round(q,2) to "log.txt".

	return true.



}
