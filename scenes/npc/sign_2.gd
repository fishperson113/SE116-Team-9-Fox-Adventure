extends Sign

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _on_interactive_area_2d_interacted() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("Dialog_cv")

func _on_dialogic_signal(argument: String):
	match argument:
		"wait_attack":
			waiting_for_action = "attack"
			Dialogic.paused = true
		"wait_throw":
			waiting_for_action = "throw"
			Dialogic.paused = true

func _process(_delta):
	if waiting_for_action == "":
		return
	
	match waiting_for_action:
		"attack":
			if Input.is_action_just_pressed("attack"):
				_resume_dialog()
		"throw":
			if Input.is_action_just_pressed("throw"):
				_resume_dialog()

func _resume_dialog():
	waiting_for_action = ""
	Dialogic.paused = false
