class_name SlipperyFloor
extends FunctionalTile

@export var friction: float = 0.995

func _ready() -> void:
	super._ready()
	_type = "slippery"

func calculate_force(internal_force: Vector2, current_force: Vector2) -> Vector2:
	var external_force := Vector2.ZERO
	external_force.x = int((current_force.x - internal_force.x) * friction)
	return external_force
