class_name Flowway
extends FunctionalTile

enum Direction { LEFT = -1, RIGHT = 1 }

@export var direction: Direction = Direction.LEFT
@export var force: float = 100

func _ready() -> void:
	super._ready()
	_type = "flowway"
	_init_animation()

func _init_animation() -> void:
	var _anim := $AnimatedSprite2D
	_anim.scale.x = -direction

func calculate_force(_internal_force: Vector2, _impulse: Vector2, _current_force: Vector2) -> Vector2:
	var external_force := Vector2.ZERO
	external_force.x += force * direction
	external_force.y += force / 2
	return external_force
