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
	control_hit()
	control_defeat()
	control_throwing(_delta)
	if obj.hit_buffer:
		obj.change_animation("hit")
	else:
		obj.change_animation("fall")
	#If on floor change to idle if not moving and not jumping
	if obj.is_on_floor():
			change_state(fsm.states.idle)
			obj.current_jump=0
	pass
