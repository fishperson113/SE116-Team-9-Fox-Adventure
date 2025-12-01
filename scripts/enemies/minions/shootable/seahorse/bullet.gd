extends BaseBullet

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()

func _on_hit_area_2d_body_entered(_body: Node2D) -> void:
	queue_free()
