extends BaseCollectible
class_name CollectibleChestKey

func _ready() -> void:
	animated_sprite.play("default")
	item_type = "item_key"
	item_detail = {}
