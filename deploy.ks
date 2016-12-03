
print "deploy".

PANELS ON.
RADIATORS ON.


FOR mypart IN ship:parts {

	if mypart:modules:contains("ModuleDeployableAntenna") {

		if mypart:getmodule("ModuleDeployableAntenna"):hasevent("extend antenna") {

			mypart:getmodule("ModuleDeployableAntenna"):doevent("extend antenna").

		}

	}

}

