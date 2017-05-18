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

do_partmodule_event("LAS","ModuleEnginesFX","activate engine").
do_partmodule_event("LAS2","ModuleEnginesFX","activate engine").
do_partmodule_event("LAS3","ModuleEnginesFX","activate engine").
do_partmodule_event("LASJET_NODE","ModuleDockingNode","decouple node").
do_partmodule_event("LASJET_NODE","ModuleAnimatedDecoupler","decouple").
do_partmodule_event("LASJET_NODE","ModuleDecouple","decouple").


