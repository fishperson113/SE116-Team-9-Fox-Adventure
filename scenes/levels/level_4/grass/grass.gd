extends FunctionalTile

@export var friction: float = 0.5

func calculate_impulse(_internal_force: Vector2, _impulse: Vector2, _current_force: Vector2) -> Vector2:
	var impulse := Vector2.ZERO
	impulse = -_impulse * 0.05
	return impulse
