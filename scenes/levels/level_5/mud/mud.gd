extends FunctionalTile

@export var walk_friction: float = 0.75
@export var jump_friction: float = 0.3

func calculate_force(_internal_force: Vector2, _impulse: Vector2, _current_force: Vector2) -> Vector2:
	var force: Vector2 = Vector2.ZERO
	force.x += -_internal_force.x * walk_friction
	force.y += -_current_force.y * jump_friction
	return force
