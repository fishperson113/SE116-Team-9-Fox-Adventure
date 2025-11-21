# stage_1.gd
extends Node2D

@export var level_number: int = 1
var is_completed: bool = false

func _ready() -> void:
	# Tìm và kết nối với finish zone nếu có
	var finish_zone = find_child("FinishZone")
	if finish_zone and finish_zone.has_signal("body_entered"):
		finish_zone.body_entered.connect(_on_finish_zone_entered)
	
	# Tìm và kết nối với boss nếu có
	var boss = find_child("Boss")
	if boss and boss.has_signal("died"):
		boss.died.connect(_on_boss_died)

# Khi player chạm finish zone
func _on_finish_zone_entered(body) -> void:
	if body.is_in_group("player") and not is_completed:
		complete_level()

# Khi boss chết
func _on_boss_died() -> void:
	if not is_completed:
		complete_level()

# Hàm hoàn thành level
func complete_level() -> void:
	is_completed = true
	
	print("Level ", level_number, " completed!")
	
	# Lưu tiến độ - mở level tiếp theo
	GameManager.complete_level(level_number)
	
	# Hiển thị màn hình hoàn thành (tùy chọn)
	show_completion_ui()
	
	# Đợi 2 giây rồi về menu chọn level
	await get_tree().create_timer(2.0).timeout
	return_to_level_selection()

# Hiển thị UI hoàn thành
func show_completion_ui() -> void:
	# Tạo label thông báo
	var completion_label = Label.new()
	completion_label.text = "LEVEL COMPLETE!"
	completion_label.add_theme_font_size_override("font_size", 48)
	completion_label.position = Vector2(get_viewport_rect().size.x / 2 - 150, get_viewport_rect().size.y / 2)
	add_child(completion_label)

# Quay về menu chọn level
func return_to_level_selection() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/level_selection.tscn")

# Gọi thủ công từ bất kỳ đâu trong stage
func _input(event: InputEvent) -> void:
	# Ví dụ: nhấn F1 để test hoàn thành level
	if event.is_action_pressed("ui_home"):  # hoặc tạo input map mới
		complete_level()
