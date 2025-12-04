extends BaseBullet

func _process(delta: float) -> void:
	rotation = velocity.angle() + PI / 2
