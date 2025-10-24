extends CanvasLayer


@onready var quit_button: Button = $Quit  
@onready var resume_button: Button = $Resume
@onready var retry_button: Button = $Retry

func _ready() -> void:
	await get_tree().process_frame
	
	get_tree().paused = true
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	
	
func _exit_tree() -> void:
	get_tree().paused = false
	queue_free()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_ui.tscn")  # Đường dẫn menu chính
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
