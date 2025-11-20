extends FunctionalTile

@export var up_friction: float = 0.2
@export var down_friction: float = 0.075

func _ready() -> void:
	super._ready()
	_type = "clingfall"

func calculate_force(_internal_force: Vector2, _impulse: Vector2, _current_force: Vector2) -> Vector2:
	var external_force := Vector2.ZERO
	if _current_force.y < 0:
		external_force.y += -_current_force.y * up_friction
	else:
		external_force.y += -_current_force.y * down_friction
	return external_force

func _on_trigger_area_2d_body_entered(body: Node2D) -> void:
	super._on_trigger_area_2d_body_entered(body)
	if body is Player:
		body.current_jump = 0
