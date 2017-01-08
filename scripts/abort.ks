
print "-shutdown all engines".

LIST ENGINES IN myVariable.
FOR eng IN myVariable {
	print "shutdown "+eng:title.
	eng:shutdown.
}.

FOR I IN RANGE(stage:number, 1) {

	print i.


	//this list changes after decouple!!

//	FOR mypart IN SHIP:PARTS {
//
//		if mypart:stage = i {
//
//			if mypart:allmodules:contains("ModuleDecouple") {
//
//				local mymod to mypart:getmodule("ModuleDecouple").
//
//				if mymod:hasevent("decouple") {
//
//					print "decouple "+mypart:title+" "+mypart:stage.
//					mymod:doevent("decouple").
//				}
//			}
//		
//			if mypart:allmodules:contains("ModuleAnchoredDecoupler") {
//
//				local mymod to mypart:getmodule("ModuleAnchoredDecoupler").
//
//				if mymod:hasevent("decouple") {
//
//					print "decouple "+mypart:title+" "+mypart:stage.
//					mymod:doevent("decouple").
//				}
//			}
//		}
//	}
}

function set_partmodule_field {
	parameter part_name.
	parameter module_name.
	parameter field_name.
	parameter field_value.

	for parapart IN SHIP:PARTSDUBBED(part_name)  {
		if parapart:allmodules:contains(module_name) {
			if parapart:getmodule(module_name):allfieldnames:contains(field_name) {
				parapart:getmodule(module_name):setfield(field_name,field_value).
			}
		}
	}
}

function do_partmodule_event {
	parameter part_name.
	parameter module_name.
	parameter event_name.

	for parapart IN SHIP:PARTSDUBBED(part_name)  {
		if parapart:allmodules:contains(module_name) {
			if parapart:getmodule(module_name):hasevent(event_name) {
				parapart:getmodule(module_name):DOEVENT(event_name).
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
	
	do_partmodule_event("HS","ModuleDecouple","jettison heat shield").
}

if SHIP:PARTSDUBBED("SMJET_DEC"):LENGTH = 1 {

	print "SMJET_DEV there & decouple".

	do_partmodule_event("SMJET_DEC","ModuleDecouple","decouple").
	do_partmodule_event("SMJET_DEC","ModuleAnimatedDecoupler","decouple").
}


set lestimestamp to time:seconds.

when time:seconds > (lestimestamp+1) then {//wait for end of accelleration

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


