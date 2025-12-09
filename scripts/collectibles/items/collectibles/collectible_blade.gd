extends BaseCollectible
class_name CollectibleBlade

func _ready() -> void:
	animated_sprite.play("default")
	item_type = "weapon_blade"
	
func _on_interaction_available() -> void:
	GameManager.add_blades(1)
	queue_free()
	pass # Replace with function body.
