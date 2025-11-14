# level_item.gd
extends TextureRect

signal level_selected(level_number: int)

@export var level_number: int
@export var is_locked: bool = false

@onready var level_background: TextureRect = $"."
@onready var level_label: Label = $LevelLabel
@onready var level_lock_sprite: TextureRect = $Lock

func _ready() -> void:
	set_level_data(level_number, is_locked)
	pass

func _on_pressed() -> void:
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
	if level_label:
		level_label.text = "LEVEL " + str(level_number)
	else:
		printerr("Node 'Level' not found in ", name)
	
	# Hiển thị/ẩn icon khóa
	if level_lock_sprite:
		level_lock_sprite.visible = is_locked
	
	# Thay đổi màu sắc background
	if level_background:
		if is_locked:
			level_background.modulate = Color(0.5, 0.5, 0.5, 0.7)
		else:
			level_background.modulate = Color(1, 1, 1, 1)
