extends VBoxContainer

@onready var num_gem = $NumGems
@onready var num_key = $NumKey
@onready var num_coin = $NumCoin
@export var player: Player = null

func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		if player.has_signal("gemsChanged"):
			player.gemsChanged.connect(update_gems)
		if player.has_signal("keysChanged"):
			player.keysChanged.connect(update_keys)
		if player.has_signal("coinsChanged"):
			player.coinsChanged.connect(update_coins)

func update_gems(count):
	num_gem.text = str(count)

func update_keys(count):
	num_key.text = str(count)

func update_coins(count):
	num_coin.text = str(count)
