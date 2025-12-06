extends CollectibleOre
class_name CollectibleOreCopper

func _ready() -> void:
	animated_sprite.play("default")
	item_detail = load("res://data/weapon/materials/copper.tres")
	item_type = item_detail.id
	pass
