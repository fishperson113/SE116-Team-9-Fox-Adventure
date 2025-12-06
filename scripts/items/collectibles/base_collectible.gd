extends Node2D
class_name BaseCollectible

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var item_type: String
var item_detail

func _ready() -> void:
	pass

func _on_interaction_available() -> void:
	print("Player touched the collectible")
	print(item_type)
	GameManager.player.item_storer.add_item(item_type, item_detail)
	queue_free()
	pass # Replace with function body.

func add_item_detail(item_detail) -> void:
	self.item_detail = item_detail

func confirm_item_type() -> void:
	print(item_type)
