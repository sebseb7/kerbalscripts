
global g_roll_correction to -90.
global correctRoll to R(0,0,g_roll_correction).
lock correctRoll to R(0,0,g_roll_correction). 

global prog_mode to 0.
global warping to 0.

//lock t_h to SHIP:GEOPOSITION:TERRAINHEIGHT.
//lock radar_alt to SHIP:ALTITUDE-( (t_h + sqrt(t_h*t_h)) / 2 ). 
lock radar_alt to ship:altitude-max(0,ship:GEOPOSITION:TERRAINHEIGHT).

set mess_queue to queue().


function logev {
	parameter text.

	print "T+"+round(missiontime,1) +": "+text+" (sAlt:"+round(radar_alt) + ") (sSpd:" + round(ship:velocity:surface:mag,1)+")".

	if homeconnection:isconnected {
		log "T+"+round(missiontime,1) +": "+text+" (sAlt:"+round(radar_alt) + ") (sSpd:" + round(ship:velocity:surface:mag,1)+")" to "0:/logs/log.txt".
	}else{
		//do logreplay
		mess_queue:push("T+"+round(missiontime,1) +": "+text+" (sAlt:"+round(radar_alt) + ") (sSpd:" + round(ship:velocity:surface:mag,1)+")").
		when homeconnection:isconnected then {
			HUDTEXT("late delivery", 5, 2, 15, red, false).
			log "***T+"+round(missiontime,1) +":late delivery: "+mess_queue:pop() to "0:/logs/log.txt".
		}
	}
	HUDTEXT(text, 5, 2, 15, red, false).
}


global tasks to list().
global groups to lexicon().
global gui to gui(200).
set gui:skin:label:fontsize to 18.
set gui:skin:button:fontsize to 10.

function register_task {
	parameter group.
	parameter name.
	parameter type.
	parameter callback.

	local task to lexicon().
	set groups[group] to 1.
	set task["group"] to group.
	set task["name"] to name.
	set task["type"] to type.
	set task["callback"] to callback.
	if type=1 callback(1,task).
	tasks:add(task).
}

function set_task_state {
	parameter task.
	parameter state.
			
	set task["state"] to state.
	if gui:visible {
		if state=0 {
			set task["led"]:pressed to false.
		}else{
			set task["led"]:pressed to true.
		}
	}
}

for file in open("/scripts/tasks"):list:values {

	if file:isfile and file:extension="ks" {
		print "RUN "+file:name.
		runpath("/scripts/tasks/"+file:name).
	}

}


function show_gui {

	if homeconnection:isconnected {

		local count to 0.

		for file in open("0:/scripts/tasks"):list:values {
	
			if file:isfile and ( not( EXISTS("/scripts/tasks/"+file:name) ) or ( not (file:readall:string = open("/scripts/tasks/"+file:name):readall:string )) ) {
				copypath("0:/scripts/tasks/"+file:name,"/scripts/tasks/"+file:name).
				PRINT "updating task: "+file:name.
				set count to count+1.
			}
		}
	
		for file in open("/scripts/tasks"):list:values {
		
			if file:isfile and ( not( EXISTS("0:/scripts/tasks/"+file:name))) {
				PRINT "delete task: "+file:name.
				deletepath("/scripts/tasks/"+file:name).
				set count to count+1.
			}

		}

		if not(count=0) {

			tasks:clear().
			groups:clear().
		
			for file in open("/scripts/tasks"):list:values {

				if file:isfile and file:extension="ks" {
					print "RUN "+file:name.
					runpath("/scripts/tasks/"+file:name).
				}
			}
		}

	}

	gui:clear().
	set gui:x to 50.
	set gui:y to 170.
	for group in groups:keys {
		local grouplayout to gui:addvlayout().
		grouplayout:addlabel(group).

		for task in tasks {
			if task["group"]=group {
				if task["type"]=0 {
					set task["button"] to grouplayout:ADDBUTTON(task["name"]).
				}
				if task["type"]=1 {
					local hbox1 to grouplayout:ADDHLAYOUT().
					set task["button"] to hbox1:ADDBUTTON(task["name"]).
					set task["led"] to hbox1:ADDRADIOBUTTON("",false).
					set task["led"]:enabled to false.
					if task:haskey("state") and task["state"]=1 {
						set task["led"]:pressed to true.
					}
				}
			}
		}
	}
	
	gui:ADDSPACING(10).
	global close TO gui:ADDBUTTON("Close").
	
	global seconds_g to sessiontime+0.25.

	when seconds_g < sessiontime then {

		if not(gui:visible) return false.

		if close:pressed gui:hide().
			
		for task in tasks {

			if task["button"]:pressed {

				task["callback"]().
			}

		}
	
		set seconds_g to sessiontime+0.25.

		return true.
	}

	gui:show().
}


