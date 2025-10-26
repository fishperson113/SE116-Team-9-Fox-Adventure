extends Bullet

func _on_hit_area_2d_hitted(area: Variant) -> void:
	queue_free()

func _on_hit_area_2d_body_entered(body: Node2D) -> void:
	queue_free()
