extends Flowway

func calculate_impulse(_internal_force: Vector2, _impulse: Vector2, _current_force: Vector2) -> Vector2:
	var impulse := Vector2.ZERO
	impulse.x += force * direction
	return impulse
