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
	control_throwing(_delta)
	control_unequip()
	control_special_ability()

	#If on floor change to idle if not moving and not jumping
	if obj.is_on_floor():
			obj.current_dash = 0
			obj.current_jump = 0
			change_state(fsm.states.idle)
	pass
