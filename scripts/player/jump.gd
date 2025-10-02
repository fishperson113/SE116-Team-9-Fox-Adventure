extends PlayerState

func _enter() -> void:
	if obj.jumpCount < obj.maxJumpCount:
		obj.change_animation("jump")
		obj.jump()
		obj.jumpCount += 1
	pass

func _update(_delta: float):
	control_jump()
	#Control moving
	control_moving()
	#If velocity.y is greater than 0 change to fall
	if obj.velocity.y > 0:
		change_state(fsm.states.fall)
	pass
