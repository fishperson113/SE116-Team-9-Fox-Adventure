extends Sign

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _on_interactive_area_2d_interacted() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("Dialog_GL")

func _on_dialogic_signal(argument: String):
	match argument:
		"wait_switch":
			waiting_for_action = "switch"
			Dialogic.paused = true
		"wait_unlock":
			waiting_for_action = "unlock"
			Dialogic.paused = true

func _process(_delta):
	if waiting_for_action == "":
		return
	
	match waiting_for_action:
		"switch":
			if Input.is_action_just_pressed("switch_item"):
				_resume_dialog()
		"unlock":
			if Input.is_action_just_pressed("unlock_chest"):
				_resume_dialog()

func _resume_dialog():
	waiting_for_action = ""
	Dialogic.paused = false
