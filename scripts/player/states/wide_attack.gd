extends PlayerState

func _enter() -> void:
	obj.create_effect("wide_attack")
	obj.get_node("Direction/WideHitArea2D/CollisionShape2D").disabled = false
	obj.wide_attack_timer.start()
	#Change animation to attack
	#if obj.velocity.y < 0:
	#	obj.change_animation("jump_attack")
	#else:
	#	obj.change_animation("attack")
	pass

func _exit() -> void:
	obj.get_node("Direction/WideHitArea2D/CollisionShape2D").disabled = true

func _update(_delta: float) -> void:
	
	pass

func _on_wide_attack_timer_timeout() -> void:
	obj.current_wide_attack += 1
	if obj.wide_attack_resolve_timer.is_stopped():
		obj.wide_attack_resolve_timer.start()
		
	if !control_moving() and !control_jump():
		change_state(fsm.states.idle)
	elif !obj.is_on_floor():
		change_state(fsm.states.fall)
	pass # Replace with function body.
