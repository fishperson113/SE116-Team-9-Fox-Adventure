extends StaticBody2D

@export var friction: float = 0.995

func applyForce(mover: BaseCharacter):
	mover.external_force += int((mover.velocity.x - mover.internal_force) * friction - mover.external_force)
	pass

func _on_trigger_area_2d_body_entered(body: Node2D) -> void:
	if body is BaseCharacter and not body.movementChanging.is_connected(applyForce):
		body.movementChanging.connect(applyForce)

func _on_trigger_area_2d_body_exited(body: Node2D) -> void:
	if body is BaseCharacter and body.movementChanging.is_connected(applyForce):
		body.movementChanging.disconnect(applyForce)
