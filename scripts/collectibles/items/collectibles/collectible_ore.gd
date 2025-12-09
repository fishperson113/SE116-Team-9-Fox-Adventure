extends BaseCollectible
class_name CollectibleOre

func _ready() -> void:
	pass
func _on_interaction_available() -> void:
	GameManager.add_material(item_type,1)
	queue_free()
