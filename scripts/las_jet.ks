
if SHIP:PARTSDUBBED("LASJET_NODE"):LENGTH = 1 {

	print "node there".

	if SHIP:PARTSDUBBED("LASJET_NODE")[0]:getmodule("ModuleDockingNode"):ALLEVENTNAMES:CONTAINS("decouple node") {
	
		print "decouple possible".

		if SHIP:PARTSDUBBED("LAS"):LENGTH = 1 {
			
			print "LAS there".


			if SHIP:PARTSDUBBED("LAS")[0]:getmodule("ModuleEnginesFX"):hasevent("activate engine") {

				print "fire".
				SHIP:PARTSDUBBED("LAS")[0]:getmodule("ModuleEnginesFX"):doevent("activate engine").

			}
		}

		print "sep".


		SHIP:PARTSDUBBED("LASJET_NODE")[0]:getmodule("ModuleDockingNode"):DOEVENT("decouple node").
	}
}

