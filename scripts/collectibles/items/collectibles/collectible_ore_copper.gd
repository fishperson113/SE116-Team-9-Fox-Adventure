extends CollectibleOre
class_name CollectibleOreCopper

func _ready() -> void:
	animated_sprite.play("default")
	item_detail = "res://data/weapon/materials/copper.tres"
	item_type = "copper"
	pass
