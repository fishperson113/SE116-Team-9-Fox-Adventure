extends PlayerState

func _enter() -> void:
	obj.change_animation("walk")
	if obj.is_on_floor():
		obj.current_jump = 0
		obj.current_dash = 0
	pass

func _update(delta: float):
	#Control jump
	control_jump()
	control_attack()
	control_throwing(delta)
	control_unequip()
	control_special_ability()
	#Control moving and if not moving change to idle
	if !control_moving():
		change_state(fsm.states.idle)
	#If not on floor change to fall
	if !obj.is_on_floor():
		if obj.velocity.y > 0:
			change_state(fsm.states.fall)
	pass
