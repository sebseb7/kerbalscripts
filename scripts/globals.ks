global g_roll_correction to -180.
global correctRoll to R(0,0,g_roll_correction).
lock correctRoll to R(0,0,g_roll_correction). 

global prog_mode to 0.
global warping to 0.

lock t_h to SHIP:GEOPOSITION:TERRAINHEIGHT.
lock radar_alt to SHIP:ALTITUDE-( (t_h + sqrt(t_h*t_h)) / 2 ). 

