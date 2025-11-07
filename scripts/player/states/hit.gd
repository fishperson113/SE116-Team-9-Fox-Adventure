extends PlayerState

func _enter() -> void:
	
	obj.change_animation("hit")
	obj.velocity.y = -250
	obj.velocity.x = -250 * sign(obj.velocity.x)
	timer = 0.5
	pass

func _update(_delta: float) -> void:
	if update_timer(_delta):
		change_state(fsm.states.idle)
