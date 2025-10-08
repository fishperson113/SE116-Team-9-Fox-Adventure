extends PlayerState

func _enter() -> void:
	obj.change_animation("jump")

func _update(_delta: float):
	control_jump()
	#Control moving
	control_moving()
	control_attack()
	control_hit()
	control_defeat()
	if obj.hit_buffer:
		obj.change_animation("hit")
	else:
		obj.change_animation("fall")
	#If velocity.y is greater than 0 change to fall
	if obj.velocity.y > 0:
		change_state(fsm.states.fall)
	pass
