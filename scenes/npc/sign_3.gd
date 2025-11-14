extends Sign

func get_timeline_name() -> String:
	return "Dialog_GL"

func _on_dialogic_signal(argument: String):
	super._on_dialogic_signal(argument)  
	
	match argument:
		"wait_switch":
			waiting_for_action = "switch"
			Dialogic.paused = true
		"wait_unlock":
			waiting_for_action = "unlock"
			Dialogic.paused = true

func _handle_action_input():
	super._handle_action_input()  
	
	match waiting_for_action:
		"switch":
			if Input.is_action_just_pressed("switch_item"):
				_resume_dialog()
		"unlock":
			if Input.is_action_just_pressed("unlock_chest"):
				_resume_dialog()
