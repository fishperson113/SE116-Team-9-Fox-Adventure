extends PlayerState

func _enter() -> void:
	obj.get_node("AttackTimer").start()
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
	#Change animation to attack
	if obj.velocity.y < 0:
		obj.change_animation("jump_attack")
	else:
		obj.change_animation("attack")
	pass

func _exit() -> void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true

func _update(_delta: float) -> void:
	#Control moving
	#control_moving()
	control_jump()
	pass

func _on_attack_timer_timeout() -> void:
	if !control_moving() and !control_jump():
		change_state(fsm.states.idle)
	elif !obj.is_on_floor():
		change_state(fsm.states.fall)
