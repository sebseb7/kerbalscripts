
print "deploy".

//PANELS ON.
//RADIATORS ON.


FOR mypart IN ship:parts {

	if mypart:modules:contains("ModuleDeployableAntenna") {

		if not(mypart:tag = "INH") and mypart:getmodule("ModuleDeployableAntenna"):hasevent("extend antenna") {

			mypart:getmodule("ModuleDeployableAntenna"):doevent("extend antenna").

		}

	}

	if mypart:modules:contains("ModuleDeployableSolarPanel") {

		if not(mypart:tag = "INH") and mypart:getmodule("ModuleDeployableSolarPanel"):hasevent("extend solar panel") {

			mypart:getmodule("ModuleDeployableSolarPanel"):doevent("extend solar panel").

		}

	}

}

