//DEORBIT
clearscreen.



SHIP:PARTSDUBBED("PARA_D1")[0]:getmodule("ModuleParachute"):setfield("min pressure",1).
SHIP:PARTSDUBBED("PARA_D1")[0]:getmodule("ModuleParachute"):setfield("altitude",100).
SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):setfield("min pressure",1).
SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):setfield("altitude",100).
SHIP:PARTSDUBBED("PARA_M2")[0]:getmodule("ModuleParachute"):setfield("min pressure",1).
SHIP:PARTSDUBBED("PARA_M2")[0]:getmodule("ModuleParachute"):setfield("altitude",100).
SHIP:PARTSDUBBED("PARA_M3")[0]:getmodule("ModuleParachute"):setfield("min pressure",1).
SHIP:PARTSDUBBED("PARA_M3")[0]:getmodule("ModuleParachute"):setfield("altitude",100).
SHIP:PARTSDUBBED("PARA_M4")[0]:getmodule("ModuleParachute"):setfield("min pressure",1).
SHIP:PARTSDUBBED("PARA_M4")[0]:getmodule("ModuleParachute"):setfield("altitude",100).





set tset to 0.
lock throttle to tset. 


SET correctRoll to R(0,0,-180). 
SAS OFF.
LOCK STEERING TO SHIP:RETROGRADE + correctRoll. 

until periapsis < 250 {
	
	if VECTORANGLE(SHIP:RETROGRADE:VECTOR,SHIP:FACING:VECTOR) < 1
	{
		set tset to 1.
		if maxthrust = 0 {
			stage.
		}
	}
	else
	{
		set tset to 0.
	}
}
set tset to 0.

until SHIP:PARTSDUBBED("SMJET_DEC"):LENGTH = 0 {
		
	if SHIP:ALTITUDE < 55000 {
	
		print "stage".
		LOCK STEERING TO SHIP:UP + correctRoll.


		if VECTORANGLE(SHIP:UP:VECTOR,SHIP:FACING:VECTOR) < 10
		{
	
			wait 1.

			SHIP:PARTSDUBBED("SMJET_DEC")[0]:getmodule("ModuleDecouple"):DOEVENT("decouple").
			if SHIP:PARTSDUBBED("LASJET_NODE"):LENGTH = 1 {
				SHIP:PARTSDUBBED("LASJET_NODE")[0]:getmodule("ModuleDockingNode"):DOEVENT("decouple node").
			}
			wait 1.
			LOCK STEERING TO SHIP:RETROGRADE + correctRoll. 

		}
	}

}
WHEN ship:velocity:surface:mag < 1500 then {
	if SHIP:PARTSDUBBED("PARA_D1")[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("deploy chute") {
		SHIP:PARTSDUBBED("PARA_D1")[0]:getmodule("ModuleParachute"):DOEVENT("deploy chute").
	}
	if SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("deploy chute") {
		SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):DOEVENT("deploy chute").
	}
	if SHIP:PARTSDUBBED("PARA_M2")[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("deploy chute") {
		SHIP:PARTSDUBBED("PARA_M2")[0]:getmodule("ModuleParachute"):DOEVENT("deploy chute").
	}
	if SHIP:PARTSDUBBED("PARA_M3")[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("deploy chute") {
		SHIP:PARTSDUBBED("PARA_M3")[0]:getmodule("ModuleParachute"):DOEVENT("deploy chute").
	}
	if SHIP:PARTSDUBBED("PARA_M4")[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("deploy chute") {
		SHIP:PARTSDUBBED("PARA_M4")[0]:getmodule("ModuleParachute"):DOEVENT("deploy chute").
	}
}

WHEN ship:velocity:surface:mag < 700 then {
	print round(missiontime) +"d1"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_D1")[0]:getmodule("ModuleParachute"):setfield("min pressure",0).
}
WHEN ship:velocity:surface:mag < 500 then {
	unlock steering.
}
WHEN ALT:RADAR < 8000 then {
	print round(missiontime) +"d2"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_D1")[0]:getmodule("ModuleParachute"):setfield("altitude",5000).
}
WHEN ALT:RADAR < 3500 then {
	if SHIP:PARTSDUBBED("PARA_D1")[0]:getmodule("ModuleParachute"):alleventnames:CONTAINS("cut parachute") {
		SHIP:PARTSDUBBED("PARA_D1")[0]:getmodule("ModuleParachute"):DOEVENT("cut parachute").
	}
	print round(missiontime) +"d3"+round(alt:radar).
}

WHEN ALT:RADAR < 3450 then {
	print round(missiontime) +"d4"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):setfield("min pressure",0).
}
WHEN ALT:RADAR < 2000 then {
	print round(missiontime) +"d5"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):setfield("min pressure",0).
}
WHEN ALT:RADAR < 1500 then {
	print round(missiontime) +"d6"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):setfield("min pressure",0).
}
WHEN ALT:RADAR < 1200 then {
	print round(missiontime) +"d7"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):setfield("min pressure",0).
}


WHEN ALT:RADAR < 800 then {
	print round(missiontime) +"d8"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_M1")[0]:getmodule("ModuleParachute"):setfield("altitude",5000).
}
WHEN ALT:RADAR < 600 then {
	print round(missiontime) +"d9"+round(alt:radar).
	if SHIP:PARTSDUBBED("HS"):LENGTH = 1 {
		SHIP:PARTSDUBBED("HS")[0]:getmodule("ModuleDecouple"):DOEVENT("jettison heat shield").
	}
}
WHEN ALT:RADAR < 300 then {
	print round(missiontime) +"d10"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_M2")[0]:getmodule("ModuleParachute"):setfield("altitude",5000).
}
WHEN ALT:RADAR < 200 then {
	print round(missiontime) +"d11"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_M3")[0]:getmodule("ModuleParachute"):setfield("altitude",5000).
}
WHEN ALT:RADAR < 50 then {
	print round(missiontime) +"d12"+round(alt:radar).
	SHIP:PARTSDUBBED("PARA_M4")[0]:getmodule("ModuleParachute"):setfield("altitude",5000).
}

wait until ALT:RADAR < 40.

unlock throttle.

