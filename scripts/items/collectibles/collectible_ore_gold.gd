extends CollectibleOre
class_name CollectibleOreGold

func _ready() -> void:
	animated_sprite.play("default")
	item_detail = load("res://data/weapon/materials/gold.tres")
	item_type = item_detail.id
	pass
