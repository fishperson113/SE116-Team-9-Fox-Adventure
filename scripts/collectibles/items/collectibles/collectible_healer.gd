extends CollectibleOre
class_name CollectibleHealer

var healing_amount: int = 35

func _ready() -> void:
	animated_sprite.play("default")
	pass

func _on_interaction_available() -> void:
	GameManager.player.heal(healing_amount)
	queue_free()
	pass
