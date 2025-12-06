extends CollectibleOre
class_name CollectibleOreIron

func _ready() -> void:
	animated_sprite.play("default")
	item_detail = load("res://data/weapon/materials/iron.tres")
	item_type = item_detail.id
	pass
