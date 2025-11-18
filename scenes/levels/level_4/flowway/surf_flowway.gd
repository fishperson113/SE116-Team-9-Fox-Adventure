extends Flowway

func calculate_impulse(impulse: Vector2, current_force: Vector2) -> Vector2:
	var _impulse := Vector2.ZERO
	_impulse.x += force * direction
	return _impulse
