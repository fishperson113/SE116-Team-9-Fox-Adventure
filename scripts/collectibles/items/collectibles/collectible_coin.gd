extends CollectibleOre
class_name CollectibleCoin

var coin_amount: int = 1

func _ready() -> void:
	animated_sprite.play("default")
	pass

func _on_interaction_available() -> void:
	AudioManager.play_sound("collect_coin")
	GameManager.add_coins(coin_amount)
	queue_free()
	pass
