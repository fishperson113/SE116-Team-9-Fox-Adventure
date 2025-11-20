class_name FunctionalTile
extends StaticBody2D

var _trigger_area: Area2D = null
var _type: String = "FunctionalTile"

func _ready() -> void:
	_trigger_area = $TriggerArea2D
	_trigger_area.body_entered.connect(_on_trigger_area_2d_body_entered)
	_trigger_area.body_exited.connect(_on_trigger_area_2d_body_exited)

func _on_trigger_area_2d_body_entered(body: Node2D) -> void:
	if body is BaseCharacter and not body.movementChanging.is_connected(apply_effect):
		body.movementChanging.connect(apply_effect)

func _on_trigger_area_2d_body_exited(body: Node2D) -> void:
	if body is BaseCharacter and body.movementChanging.is_connected(apply_effect):
		body.movementChanging.disconnect(apply_effect)

func apply_effect(_mover: BaseCharacter):
	apply_force(_mover)
	apply_impulse(_mover)

func apply_impulse(_mover: BaseCharacter):
	var impulse := calculate_impulse(_mover.internal_force, _mover.impulse, _mover.velocity)
	
	_mover.apply_impulse(impulse)
	pass

# Whatever inheriting from this script should only ovveride this method
func calculate_impulse(_internal_force: Vector2, _impulse: Vector2, _current_force: Vector2) -> Vector2:
	# Calculate impulse here
	return Vector2.ZERO

func apply_force(_mover: BaseCharacter):
	if _mover.has_force(_type):
		return
	
	var external_force := calculate_force(_mover.internal_force, _mover.impulse, _mover.velocity)
	if external_force == Vector2.ZERO:
		return

	_mover.apply_force(_type, external_force)
	pass

# Whatever inheriting from this script should only ovveride this method
func calculate_force(_internal_force: Vector2, _impulse: Vector2, _current_force: Vector2) -> Vector2:
	# Calculate mover.external_force here
	return Vector2.ZERO
