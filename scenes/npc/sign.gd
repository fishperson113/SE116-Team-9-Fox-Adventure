class_name Sign
extends Node2D

var waiting_for_action = ""
var player = null
var is_dialog_active = false
@onready var label = $Label
@onready var exit_button = $CanvasLayer/Button
@onready var dialog_layer = $Dialoglayer

func _ready():
	player = get_tree().get_first_node_in_group("player")
	label.visible = false
	exit_button.visible = false
	exit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	exit_button.pressed.connect(_on_exit_button_pressed)

func get_timeline_name() -> String:
	return "timeline" 

func _on_interactive_area_2d_interacted() -> void:
	_start_dialog(get_timeline_name())

func _start_dialog(timeline_name: String) -> void:
	if is_dialog_active:
		return
	is_dialog_active = true
	exit_button.visible = true
	Dialogic.signal_event.connect(_on_dialogic_signal)
	var dialog = Dialogic.start(timeline_name)
	Dialogic.paused = false  
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in dialog.get_children():
		child.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(dialog)
	await get_tree().process_frame
	
	if player:
		player.set_physics_process(false)
		player.set_process_input(false)
		player.velocity = Vector2.ZERO
	
	Dialogic.timeline_ended.connect(_on_timeline_ended, CONNECT_ONE_SHOT)

func _on_exit_button_pressed():
	close_dialog()

func close_dialog():
	Dialogic.end_timeline()
	is_dialog_active = false
	waiting_for_action = ""
	exit_button.visible = false
	
	if player:
		player.set_physics_process(true)
		player.set_process_input(true)
	
	if Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.disconnect(_on_dialogic_signal)

func _on_timeline_ended():
	is_dialog_active = false
	waiting_for_action = ""
	exit_button.visible = false
	
	if player:
		player.set_physics_process(true)
		player.set_process_input(true)
	
	if Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.disconnect(_on_dialogic_signal)

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

func _handle_action_input():
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

func _process(_delta):
	if waiting_for_action == "":
		return
	_handle_action_input()

func _resume_dialog():
	waiting_for_action = ""
	Dialogic.paused = false

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		label.visible = true

func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		label.visible = false
