extends CollectibleOre
class_name CollectibleOreGold

func _ready() -> void:
	animated_sprite.play("default")
	item_detail = "res://data/weapon/materials/gold.tres"
	item_type = "gold"
	pass
