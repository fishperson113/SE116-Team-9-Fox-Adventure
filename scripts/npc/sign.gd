class_name Sign
extends Node2D

@export var timeline_name: String = ""   

var is_dialog_active := false
var dialog_instance: Node = null

@onready var label = $Label

func _on_interactive_area_2d_interacted() -> void:
	if timeline_name == "":
		push_warning("Chưa nhập timeline_name trong Inspector!")
		return
	
	if is_dialog_active:
		return

	_start_dialog()

func _start_dialog():
	is_dialog_active = true
	
	dialog_instance = Dialogic.start(timeline_name)
	get_tree().root.add_child(dialog_instance)

	Dialogic.timeline_ended.connect(_on_timeline_ended, CONNECT_ONE_SHOT)

func close_dialog():
	if dialog_instance:
		Dialogic.end_timeline()
	is_dialog_active = false

func _on_timeline_ended():
	is_dialog_active = false
	dialog_instance = null

func _process(delta):
	if not is_dialog_active:
		return

	if Input.is_action_pressed("left") \
	or Input.is_action_pressed("right") \
	or Input.is_action_pressed("jump"):

		close_dialog()

func _on_detection_area_2d_body_entered(body):
	if body.name == "Player":
		label.visible = true

func _on_detection_area_2d_body_exited(body):
	if body.name == "Player":
		label.visible = false
