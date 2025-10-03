extends PlayerState

func _enter() -> void:
	#Change animation to attack
	if obj.velocity.y < 0:
		obj.change_animation("jump_attack")
	else:
		obj.change_animation("attack")
	pass

func _update(_delta: float) -> void:
	#Control moving
	control_moving()
	control_jump()
	pass

func _on_attack_animation_finished() -> void:
	if $"../../Direction/AnimatedSprite2D".animation.find("attack") != -1:
		if !control_moving() and !control_jump():
			change_state(fsm.states.idle)
		elif !obj.is_on_floor():
			change_state(fsm.states.fall)
	pass # Replace with function body.
