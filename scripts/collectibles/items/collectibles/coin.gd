extends BaseCollectible
class_name Coin

func _ready() -> void:
	animated_sprite.play("default")
	item_type = "item_coin"
	
func _on_interaction_available() -> void:
	GameManager.add_coins(1)
	queue_free()
	pass # Replace with function body.
