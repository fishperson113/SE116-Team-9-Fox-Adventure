extends Node2D

func _ready() -> void:
	$QuitButton.connect("button_down", Callable(self, "_on_quit_button_down"))
	set_up_levels()

func set_up_levels():
	var grid_container = $ScrollContainer/GridContainer
	var level_items = grid_container.get_children()
	for i in range(level_items.size()):
		var level_item = level_items[i]
		
		level_item.set_level_data(i + 1, false)
		
		if level_item.has_signal("level_selected"):
			level_item.level_selected.connect(_on_level_selected)
			
func _on_level_selected(level_num: int):
	load_level(level_num)
	
func load_level(num: int):
	#Global.current_level = num
	
	var level_path = "res://scenes/levels/level_1/stage_" + str(1) + ".tscn"
	
	if ResourceLoader.exists(level_path):
		get_tree().change_scene_to_file(level_path)
	else:
		print("Level không tồn tại: ", level_path)
		
func _on_quit_button_down():
	get_tree().change_scene_to_file("res://scenes/ui/Entrance.tscn")
	pass
