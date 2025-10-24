extends Node2D

func _ready() -> void:
	$SettingsButton.connect("button_down", Callable(self, "_on_settings_button_down"))

func _on_settings_button_down():
	var scene = load("res://scenes/ui/Setting.tscn").instantiate()
	
	get_tree().root.add_child(scene)
	
	var control = scene.get_child(0)
	control.set_anchors_preset(Control.PRESET_CENTER)
	control.position = Vector2.ZERO
	get_tree().paused = true
	
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
