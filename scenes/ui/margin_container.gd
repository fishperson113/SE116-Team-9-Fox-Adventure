extends MarginContainer

func _ready() -> void:
	$SettingsButton.connect("button_down", Callable(self, "_on_settings_button_down"))

func _on_settings_button_down():
	var scene = load("res://scenes/ui/Setting.tscn").instantiate()
	get_parent().add_child(scene)
