extends CanvasLayer

func _ready() -> void:
	$QuitButton.connect("button_down", Callable(self, "_on_quit_button_down"))
	set_up_levels()

func set_up_levels():
	var grid_container = $ScrollContainer/GridContainer
	var level_items = grid_container.get_children()
	
	for i in range(level_items.size()):
		var level_item = level_items[i]
		var level_num = i + 1
		
		var is_locked = not GameManager.is_level_unlocked(level_num)
		
		level_item.set_level_data(level_num, is_locked)
		
		if level_item.has_signal("level_selected"):
			level_item.level_selected.connect(_on_level_selected)

func _on_level_selected(level_num: int):
	if GameManager.is_level_unlocked(level_num):
		hide()
		await get_tree().process_frame 
		load_level(level_num)

func load_level(num: int):
	var level_path = "res://scenes/levels/level_" + str(num) + "/stage_1.tscn"
	
	if ResourceLoader.exists(level_path):
		get_tree().change_scene_to_file(level_path)

func _on_quit_button_down():
	queue_free()
