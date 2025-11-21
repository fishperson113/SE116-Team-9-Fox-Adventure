extends TextureProgressBar

@export var player: Player = null

func _ready() -> void:
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		push_warning("No player found in scene!")
		return
	player.healthChanged.connect(update)
	update()
	
func update():
	if player == null:
		return
	value = player.currentHealth*100/player.maxHealth
