class_name SlipperyFloor
extends FunctionalTile

@export var friction: float = 0.99

func _ready() -> void:
	super._ready()
	_type = "slippery"

func calculate_force(internal_force: Vector2, impulse: Vector2, current_force: Vector2) -> Vector2:
	var _external_force := Vector2.ZERO
	_external_force.x += -internal_force.x
	return _external_force

func calculate_impulse(internal_force: Vector2, impulse: Vector2, current_force: Vector2) -> Vector2:
	var _impulse := Vector2.ZERO
	var fill_impulse = current_force.x - impulse.x
	var sliding_impulse = (internal_force.x - current_force.x) * (1 - friction)
	_impulse.x +=  fill_impulse + sliding_impulse
	return _impulse

# The wind fomula
#func calculate_impulse(internal_force: Vector2, impulse: Vector2, current_force: Vector2) -> Vector2:
	#var _impulse := Vector2.ZERO
	#_impulse.x += (current_force.x - internal_force.x) * friction - impulse.x
	#return _impulse
