# level_item.gd
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
			else:
				print("Level ", level_number, " đang bị khóa!")

func set_level_data(num: int, locked: bool = false):
	level_number = num
	is_locked = locked
	
	# Sử dụng call_deferred để đảm bảo update sau khi scene ready
	call_deferred("update_visual")

func update_visual():
	# Cập nhật text label
	var label = get_node_or_null("Level")
	if label:
		label.text = "LEVEL " + str(level_number)
	else:
		printerr("Node 'Level' not found in ", name)
	
	# Hiển thị/ẩn icon khóa
	var lock = get_node_or_null("Lock")
	if lock:
		lock.visible = is_locked
	
	# Thay đổi màu sắc background
	var background = get_node_or_null("Background")
	if background:
		if is_locked:
			background.modulate = Color(0.5, 0.5, 0.5, 0.7)
		else:
			background.modulate = Color(1, 1, 1, 1)


func _on_level_selected(level_number: int) -> void:
	pass # Replace with function body.
