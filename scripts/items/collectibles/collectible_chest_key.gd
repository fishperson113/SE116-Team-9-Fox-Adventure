extends BaseCollectible
class_name CollectibleChestKey

func _on_interaction_available() -> void:
	print("Player touched the chest key")
	GameManager.player.inventory.insert_item("item_key", {})
	queue_free()
	pass
