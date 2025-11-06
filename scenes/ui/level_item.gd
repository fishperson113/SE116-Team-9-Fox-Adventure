extends Area2D

signal level_selected(level_number: int)

var level_number: int = 1
var is_locked: bool = false

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if not is_locked:
				level_selected.emit(level_number)

func set_level_data(num: int, locked: bool = false):
	level_number = num
	is_locked = locked
	
	if has_node("Label"):
		$Label.text = "LEVEL" + str(level_number)
