#extends Sign
#
#func _ready():
	#player = get_tree().get_first_node_in_group("player")
#
#func _on_interactive_area_2d_interacted() -> void:
	#Dialogic.start("turtle_dialog")
extends Sign

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _on_interactive_area_2d_interacted() -> void:
	Dialogic.timeline_ended.connect(_on_dialog_ended)
	Dialogic.start("turtle_dialog")

func _on_dialog_ended():
	Dialogic.timeline_ended.disconnect(_on_dialog_ended)
	
	var current_level = 1
	GameManager.complete_level(current_level)
	
	show_win_ui()

func show_win_ui():
	var win_ui_scene = load("res://scenes/ui/WinUI.tscn")
	var win_ui_instance = win_ui_scene.instantiate()
	
	get_tree().root.add_child(win_ui_instance)
	
