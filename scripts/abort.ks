
print "-shutdown all engines".

LIST ENGINES IN myVariable.
FOR eng IN myVariable {
	print "shutdown "+eng:title.
	eng:shutdown.
}.

FOR I IN RANGE(stage:number, 1) {

	print i.


	//this list changes after decouple!!

	FOR mypart IN SHIP:PARTS {

		if mypart:stage = i {

			if mypart:allmodules:contains("ModuleDecouple") {

				local mymod to mypart:getmodule("ModuleDecouple").

				if mymod:hasevent("decouple") {

					print "decouple "+mypart:title+" "+mypart:stage.
					mymod:doevent("decouple").
				}
			}
		
			if mypart:allmodules:contains("ModuleAnchoredDecoupler") {

				local mymod to mypart:getmodule("ModuleAnchoredDecoupler").

				if mymod:hasevent("decouple") {

					print "decouple "+mypart:title+" "+mypart:stage.
					mymod:doevent("decouple").
				}
			}
		}
	}
}

if SHIP:PARTSDUBBED("LAS"):LENGTH = 1 {
		
	print "LAS there".

	if SHIP:PARTSDUBBED("LAS")[0]:getmodule("ModuleEnginesFX"):hasevent("activate engine") {

	lock steering to ship:prograde.
	RCS ON.

	print "fire".
		SHIP:PARTSDUBBED("LAS")[0]:getmodule("ModuleEnginesFX"):doevent("activate engine").
	}
}
		
if SHIP:PARTSDUBBED("HS"):LENGTH = 1 {

	print "HS there & decouple".
	SHIP:PARTSDUBBED("HS")[0]:getmodule("ModuleDecouple"):DOEVENT("jettison heat shield").
}

set lestimestamp to time:seconds.

when time:seconds > (lestimestamp+1) then {

	lock steering to ship:SRFRETROGRADE.
	run las_jet.

	set lestimestamp to time:seconds.
	when (time:seconds > (lestimestamp+3))or(VECTORANGLE(SHIP:SRFRETROGRADE:VECTOR,SHIP:FACING:VECTOR) < 20) then
	{
		unlock steering.
		RCS Off.
		run deorbit.
	}
}


