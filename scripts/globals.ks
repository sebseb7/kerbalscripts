global g_roll_correction to -90.
global correctRoll to R(0,0,g_roll_correction).
lock correctRoll to R(0,0,g_roll_correction). 

global prog_mode to 0.
global warping to 0.

lock t_h to SHIP:GEOPOSITION:TERRAINHEIGHT.
lock radar_alt to SHIP:ALTITUDE-( (t_h + sqrt(t_h*t_h)) / 2 ). 




function logev {
	parameter text.

	print "T+"+round(missiontime,1) +": "+text+" (sAlt:"+round(radar_alt) + ") (sSpd:" + round(ship:velocity:surface:mag,1)+")".

	if homeconnection:isconnected {
		log "T+"+round(missiontime,1) +": "+text+" (sAlt:"+round(radar_alt) + ") (sSpd:" + round(ship:velocity:surface:mag,1)+")" to "0:/logs/log.txt".
	}else{
		//do logreplay
		when homeconnection:isconnected then {
			log "***T+"+round(missiontime,1) +": "+text+" (sAlt:"+round(radar_alt) + ") (sSpd:" + round(ship:velocity:surface:mag,1)+")" to "0:/logs/log.txt".
		}
	}
	HUDTEXT(text, 5, 2, 15, red, false).
}
			
