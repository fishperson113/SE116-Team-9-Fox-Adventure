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
	GameManager.player.inventory.insert_item(item_type,item_detail)
	GameManager.player.inventory.save_inventory()
	GameManager.player.item_storer.add_item(item_type, item_detail)
	GameManager.player.item_storer.save_slots()
	queue_free()
	pass # Replace with function body.

func add_item_detail(item_detail) -> void:
	self.item_detail = item_detail

func confirm_item_type() -> void:
	print(item_type)
