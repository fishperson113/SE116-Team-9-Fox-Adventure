extends FunctionalTile

@export var up_friction: float = 0.12
@export var down_friction: float = 0.05

func applyForce(_mover: BaseCharacter):
	if _mover.velocity.y < 0:
		_mover.external_force.y += -_mover.velocity.y * up_friction
	else:
		_mover.external_force.y += -_mover.velocity.y * down_friction
	pass

func _on_trigger_area_2d_body_entered(body: Node2D) -> void:
	super._on_trigger_area_2d_body_entered(body)
	if body is Player:
		body.current_jump = 0
