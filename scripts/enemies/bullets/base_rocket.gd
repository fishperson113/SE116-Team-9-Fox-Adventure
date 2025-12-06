class_name BaseRocket
extends BaseBullet

func _process(delta: float) -> void:
	rotation = compute_facing_angle(velocity)

func compute_facing_angle(_velocity: Vector2) -> float:
	return _velocity.angle() + PI / 2
