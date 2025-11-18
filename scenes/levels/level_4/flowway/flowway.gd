class_name Flowway
extends FunctionalTile

enum Direction { LEFT = -1, RIGHT = 1 }

@export var direction: Direction = Direction.LEFT
@export var force: float = 100

func _ready() -> void:
	super._ready()
	_type = "flowway"

func calculate_force(internal_force: Vector2, impulse: Vector2, current_force: Vector2) -> Vector2:
	var external_force := Vector2.ZERO
	external_force.x += force * direction
	external_force.y += force / 2
	return external_force
