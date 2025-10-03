extends PlayerState

func _enter() -> void:
	obj.change_animation("walk")
	pass

func _update(delta: float):
	#Control jump
	control_jump()
	control_attack()
	#Control moving and if not moving change to idle
	if !control_moving():
		change_state(fsm.states.idle)
	#If not on floor change to fall
	if !obj.is_on_floor():
		if obj.velocity.y > 0:
			change_state(fsm.states.fall)
		else:
			obj.change_animation("jump")
	else:
		obj.jumpCount = 0
	pass
