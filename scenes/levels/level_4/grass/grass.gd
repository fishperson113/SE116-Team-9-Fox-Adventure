extends FunctionalTile

@export var friction: float = 0.5

func calculate_impulse(internal_force: Vector2, impulse: Vector2, current_force: Vector2) -> Vector2:
	var _impulse := Vector2.ZERO
	_impulse = -impulse * 0.05
	return _impulse
