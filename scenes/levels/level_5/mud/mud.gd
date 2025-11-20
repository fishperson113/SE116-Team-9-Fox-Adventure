extends FunctionalTile

@export var friction: float = 0.75

func calculate_force(_internal_force: Vector2, _impulse: Vector2, _current_force: Vector2) -> Vector2:
	var force: Vector2 = Vector2.ZERO
	force.x += -_internal_force.x * friction
	force.y += absf(_current_force.y) * (1 - friction)
	return force
