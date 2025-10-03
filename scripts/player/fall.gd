extends PlayerState

func _enter() -> void:
	#Change animation to fall
	obj.change_animation("fall")
	pass

func _update(_delta: float) -> void:
	#Control moving
	control_moving()
	control_jump()
	control_attack()
	#If on floor change to idle if not moving and not jumping
	if obj.is_on_floor():
		if !control_moving() and !control_jump():
			change_state(fsm.states.idle)
	pass
