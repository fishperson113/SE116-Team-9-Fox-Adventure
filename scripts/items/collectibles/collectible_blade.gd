extends BaseCollectible
class_name CollectibleBlade

func _ready() -> void:
	animated_sprite.play("default")
	item_type = "weapon_blade"
