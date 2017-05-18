global land_gui to gui(200).
global lgui_events to lexicon().
global land_active to false.

//set targetlong to -12.75.
//set targetlong to 179.

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
	
	
function deploy_legs {
	
	set ok to 0.
	FOR mypart IN ship:parts {
		
		if not(mypart:tag = "INH") and mypart:modules:contains("ModuleWheelDeployment") {

			if mypart:getmodule("ModuleWheelDeployment"):hasevent("Extend") {
				if ok = 0 {
					mypart:getmodule("ModuleWheelDeployment"):DOEVENT("Extend").
				}
				set ok to 1.
			}
		}
	}
}

function mun_deorbit {

	do_partmodule_event("LM_DESC","ModuleEnginesFX","activate engine").

	//if ship:velocity:orbit:mag > 200 {
	if ship:velocity:orbit:mag > 80 {

		//set burnvector to lookdirup(ship:retrograde:vector, ship:facing:topvector).
		unlock steering.
		sas off.
		//lock steering to burnvector.
		lock steering to lookdirup(ship:retrograde:vector, ship:facing:topvector).

		when (land_active = false) or (VECTORANGLE(ship:retrograde:vector,SHIP:FACING:VECTOR) < 5) then {

			if land_active = false { unlock steering.return false.}

			lock throttle to 1.
	
			when (land_active = false) or (ship:velocity:orbit:mag < 80) then {

				if land_active = false { unlock throttle.unlock steering.return false.}
		
				unlock throttle.
				unlock steering.
				sas on.
				logev("deorbit done").
				mun_ssburn().
			}
		}
	}else{
		mun_ssburn().
	}
}

//-18.608

function mun_prepare_deorbit {
	
	unlock steering.
	sas on.
	SET SASMODE TO "RETROGRADE".

	when (land_active = false) or ((VECTORANGLE(ship:retrograde:vector,SHIP:FACING:VECTOR) < 0.05 )and(ship:angularmomentum:mag < 0.1)) then {
			
		if land_active = false { unlock steering.sas off.return false.}

		SET SASMODE TO "STABILITYASSIST".

		when (land_active = false) or (ship:longitude > 9) then {
		
			if land_active = false { unlock steering.set warp to 0.return false.}
	
			when (land_active = false) or (ship:longitude < 9) then {
			
				if land_active = false { unlock steering.set warp to 0.return false.}
	
				set warp to 0.
				mun_deorbit().
		
			}
		}
		set warp to 3.
	}
	

}

function mun_ssburn {
		
	set warp to 3.

	sas off.
	lock steering to lookdirup(ship:srfretrograde:vector, ship:facing:topvector).

	when true then {
		if land_active = false { unlock throttle.unlock steering.set warp to 0. return false.}
	
		set stopat to 1.5.
		set x_grav to body:mu/((body:radius+SHIP:GEOPOSITION:TERRAINHEIGHT)^2).
		set ssb_alt2 to 1.1* ((2 * x_grav * (max(0,radar_alt-stopat))) + ship:verticalspeed^2) / (2.0 * ((maxthrust*sin(90-min(60,VECTORANGLE(SHIP:UP:VECTOR,SHIP:facing:VECTOR))))/ship:mass)).
	
		if (ssb_alt2-(radar_alt-stopat)) > 0 {set warp to 0. }

		lock throttle to (ssb_alt2-(radar_alt-stopat)).

		if radar_alt < stopat {unlock throttle. unlock steering. set land_active to false. land_gui:hide. return false.}

		print ssb_alt2+" "+ssb_alt2+" "+radar_alt.
		return true.
	}
	
	when (land_active = false) or (radar_alt < 1000) then {
		if land_active = false {return false.}
		deploy_legs().
	}
}

function init_land_gui {

	set land_gui:x to 50.
	set land_gui:y to 130.//von oben
	set land_gui:skin:label:fontsize to 15.
	set land_gui:skin:button:fontsize to 10.
	set land_gui:skin:button:height to 15.
	
	lgui_events:add("long",land_gui:ADDTEXTFIELD("0")).
	lgui_events:add("go",land_gui:addbutton("go")).
	lgui_events:add("lon",land_gui:addbutton("lon")).
	lgui_events:add("close",land_gui:addbutton("Close")).
	
}

function check_lbuttons {

	if lgui_events["go"]:pressed {
		mun_deorbit().
	}
	if lgui_events["lon"]:pressed {
		mun_prepare_deorbit().
	}
	if lgui_events["long"]:confirmed {
		//
	}

	if lgui_events["close"]:pressed {
		SET SHIP:CONTROL:NEUTRALIZE to TRUE.
		land_gui:hide.
		unlock steering.
		sas on.
		rcs off.
		set land_active to false.
	}
}


function open_land_window {

	if land_active = false {

		on round(time:seconds,1) {

			check_lbuttons().

			if land_active = false {
				return false.
			}

			return true.
		}
	
		set land_active to true.
	}

	if land_gui:widgets:length = 0 {
		init_land_gui().
	}

	land_gui:show().

}



//if (1=2)and(ship:periapsis > 12000) {
//
//	unlock steering.
//	sas on.
//	set kuniverse:timewarp:mode to "RAILS".
//	set warp to 4.
//	print ship:longitude.
//	wait until ship:longitude > diff. 
//	print ship:longitude.
//	wait until ship:longitude < diff.
//	print diff+" "+ship:longitude.
//	set warp to 0.
//	sas off.
//	lock steering to lookdirup(ship:retrograde:vector, ship:facing:topvector).
//	wait until VECTORANGLE(ship:retrograde:vector,SHIP:FACING:VECTOR) < 1.
//	unlock steeting.
//	sas on.
//	set kuniverse:timewarp:mode to "PHYSICS".
//	set warp to 2.
//	wait until ship:longitude < pretarget.
//	print pretarget+" "+ship:longitude.
//	sas off.
//}

