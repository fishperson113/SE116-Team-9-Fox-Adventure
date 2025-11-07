extends Sign

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _on_interactive_area_2d_interacted() -> void:
	Dialogic.start("mushroom_dialog")
