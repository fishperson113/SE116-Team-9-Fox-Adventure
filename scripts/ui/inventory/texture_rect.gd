extends TextureRect

func _get_drag_data(at_position: Vector2) -> Variant:
	return texture
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Texture2D

func _drop_data(at_position: Vector2, data: Variant) -> void:
	texture = data
