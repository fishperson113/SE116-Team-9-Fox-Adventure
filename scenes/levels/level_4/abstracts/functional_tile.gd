class_name FunctionalTile
extends StaticBody2D

var _trigger_area: Area2D = null

func _ready() -> void:
	_trigger_area = $TriggerArea2D
	_trigger_area.body_entered.connect(_on_trigger_area_2d_body_entered)
	_trigger_area.body_exited.connect(_on_trigger_area_2d_body_exited)

func applyForce(_mover: BaseCharacter):
	# Calculate mover.external_force here
	pass

func _on_trigger_area_2d_body_entered(body: Node2D) -> void:
	if body is BaseCharacter and not body.movementChanging.is_connected(applyForce):
		body.movementChanging.connect(applyForce)

func _on_trigger_area_2d_body_exited(body: Node2D) -> void:
	if body is BaseCharacter and body.movementChanging.is_connected(applyForce):
		body.movementChanging.disconnect(applyForce)
