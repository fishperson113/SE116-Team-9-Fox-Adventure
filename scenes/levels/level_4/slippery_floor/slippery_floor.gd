class_name SlipperyFloor
extends FunctionalTile

@export var friction: Vector2 = Vector2(0.99, 0.15)

func _ready() -> void:
	super._ready()
	_type = "slippery"

func calculate_force(_internal_force: Vector2, _impulse: Vector2, current_force: Vector2) -> Vector2:
	var _external_force := Vector2.ZERO
	_external_force.x += -_internal_force.x
	_external_force.y += current_force.y * -friction.y
	return _external_force

func calculate_impulse(_internal_force: Vector2, _impulse: Vector2, current_force: Vector2) -> Vector2:
	var impulse := Vector2.ZERO
	var fill_impulse = current_force.x - _impulse.x
	var sliding_impulse = (_internal_force.x - current_force.x) * (1 - friction.x)
	impulse.x +=  fill_impulse + sliding_impulse
	return impulse

func _on_trigger_area_2d_body_entered(body: Node2D) -> void:
	super._on_trigger_area_2d_body_entered(body)
	if body is Player:
		body.current_jump = 1

# The wind fomula
#func calculate_impulse(_internal_force: Vector2, _impulse: Vector2, current_force: Vector2) -> Vector2:
	#var _impulse := Vector2.ZERO
	#_impulse.x += (current_force.x - _internal_force.x) * friction - _impulse.x
	#return _impulse
