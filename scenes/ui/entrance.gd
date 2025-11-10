extends CanvasLayer

func _ready() -> void:
	$PlayNow/Button.connect("button_down", Callable(self, "_on_button_pressed").bind("Level"))
	$Inventory/Button.connect("button_down", Callable(self, "_on_button_pressed").bind("Inventory"))
	$Farm/Button.connect("button_down", Callable(self, "_on_button_pressed").bind("Farm"))
	$Forge/Button.connect("button_down", Callable(self, "_on_button_pressed").bind("Forge"))
	$Quit/Button.connect("button_down", Callable(self, "_on_button_pressed").bind("Quit"))
	$SettingsButton.connect("button_down", Callable(self, "_on_settings_button_down"))

func _on_button_pressed(button_name: String) -> void:
	print("🔴 _on_button_pressed called with:", button_name)
	match button_name:
		"Level":
			var scene = load("res://scenes/ui/Starting.tscn").instantiate()
			var nine_patch = scene.get_node("NinePatchRect")
			get_tree().root.add_child(scene)
			if nine_patch:
				var viewport_size = get_viewport().get_visible_rect().size
				nine_patch.position = (viewport_size - nine_patch.size) / 2
			hide()
		"Quit":
			print("Quitting game...")  
			get_tree().quit()
		
func _change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
		
func _on_settings_button_down():
	var scene = load("res://scenes/ui/Setting.tscn").instantiate()
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().root.add_child(scene)
	
	var nine_patch = scene.get_node("NinePatchRect")
	if nine_patch:
		var viewport_size = get_viewport().get_visible_rect().size
		nine_patch.position = (viewport_size - nine_patch.size) / 2
	
	get_tree().paused = true
