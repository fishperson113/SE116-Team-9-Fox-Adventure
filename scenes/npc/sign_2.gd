extends Sign

func get_timeline_name() -> String:
	return "Dialog_cv"

func _on_dialogic_signal(argument: String):
	super._on_dialogic_signal(argument)  
	
	match argument:
		"wait_attack":
			waiting_for_action = "attack"
			Dialogic.paused = true
		"wait_throw":
			waiting_for_action = "throw"
			Dialogic.paused = true

func _handle_action_input():
	super._handle_action_input()  
	
	match waiting_for_action:
		"attack":
			if Input.is_action_just_pressed("attack"):
				_resume_dialog()
		"throw":
			if Input.is_action_just_pressed("throw"):
				_resume_dialog()
