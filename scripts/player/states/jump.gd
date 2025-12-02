extends PlayerState

func _enter() -> void:
	obj.change_animation("jump")

func _update(_delta: float):
	control_jump()
	control_dash()
	#Control moving
	control_moving()
	control_attack()
	control_wide_attack()
	control_throwing(_delta)
	control_unequip()
	#If velocity.y is greater than 0 change to fall
	if obj.velocity.y > 0:
		change_state(fsm.states.fall)
	pass
