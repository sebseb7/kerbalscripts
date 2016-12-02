
print "-shutdown all engines".

LIST ENGINES IN myVariable.
FOR eng IN myVariable {
	eng:shutdown.
}.

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

when time:seconds > (lestimestamp+1) then
{

	lock steering to ship:retrograde.
	run las_jet.

	set lestimestamp to time:seconds.
	when time:seconds > (lestimestamp+4) then
	{
		unlock steering.
		run do.
	}

}

