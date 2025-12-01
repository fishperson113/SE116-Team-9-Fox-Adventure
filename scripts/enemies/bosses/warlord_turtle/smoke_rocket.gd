extends BaseBullet

func _process(delta: float) -> void:
	super._process(delta)
	rotation = velocity.angle() + PI / 2
	pass
