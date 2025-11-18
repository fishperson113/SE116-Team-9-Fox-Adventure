extends Flowway

func calculate_impulse(internal_force: Vector2, current_force: Vector2) -> Vector2:
	var impulse := Vector2.ZERO
	impulse.x += force * direction
	return impulse
