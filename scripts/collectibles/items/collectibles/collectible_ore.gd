extends BaseCollectible
class_name CollectibleOre

func _ready() -> void:
	pass
func _on_interaction_available() -> void:
	AudioManager.play_sound("collect_ore")
	GameManager.add_material(item_type,1)
	queue_free()
