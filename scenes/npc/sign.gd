class_name Sign
extends Node2D

var waiting_for_action = ""
var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	

func _on_interactive_area_2d_interacted() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("timeline")

func _on_dialogic_signal(argument: String):
	match argument:
		"wait_move_left":
			waiting_for_action = "move_left"
			Dialogic.paused = true
		"wait_move_right":
			waiting_for_action = "move_right"
			Dialogic.paused = true
		"wait_jump":
			waiting_for_action = "jump"
			Dialogic.paused = true

func _process(_delta):
	if waiting_for_action == "":
		return
	
	match waiting_for_action:
		"move_left":
			if Input.is_action_pressed("left"):
				_resume_dialog()
		"move_right":
			if Input.is_action_pressed("right"):
				_resume_dialog()
		"jump":
			if Input.is_action_just_pressed("jump"):
				_resume_dialog()

func _resume_dialog():
	waiting_for_action = ""
	Dialogic.paused = false
