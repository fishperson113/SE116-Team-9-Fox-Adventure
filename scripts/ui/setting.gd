extends CanvasLayer

@onready var quit_button: Button = %Quit  
@onready var resume_button: Button = %Resume
@onready var retry_button: Button = %Retry

@onready var music_check_button: CheckButton = $NinePatchRect/SoundCheckButton
@onready var sfx_check_button: CheckButton = $NinePatchRect/SFXCheckButton

func _ready() -> void:
	await get_tree().process_frame
	
	get_tree().paused = true
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if music_check_button:
		if AudioManager.get_bus_volume("Music") > -80.0:
			music_check_button.button_pressed = true
		else:
			music_check_button.button_pressed = false
	if sfx_check_button:
		if AudioManager.get_bus_volume("SFX") > -80.0:
			sfx_check_button.button_pressed = true
		else:
			sfx_check_button.button_pressed = false

func _exit_tree() -> void:
	get_tree().paused = false
	queue_free()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/Entrance.tscn") 
	queue_free()

func _on_resume_pressed() -> void:
	hide_popup()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func hide_popup():
	get_tree().paused = false
	queue_free()

func _on_overlay_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_popup()

func _on_close_texture_button_pressed() -> void:
	hide_popup()

func _on_music_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.set_bus_volume("Music", 0.0)
	else:
		AudioManager.set_bus_volume("Music", -80.0)
	pass # Replace with function body.

func _on_sfx_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.set_bus_volume("SFX", 0.0)
	else:
		AudioManager.set_bus_volume("SFX", -80.0)
	pass # Replace with function body.
