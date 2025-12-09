extends CollectibleOre
class_name CollectibleOreIron

func _ready() -> void:
	animated_sprite.play("default")
	item_detail = "res://data/weapon/materials/iron.tres"
	item_type = "iron"
	pass
