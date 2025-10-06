extends PlayerState

func _enter() -> void:
	if !deduct_health(15):
		change_state(fsm.states.defeat)
	
	obj.hit_buffer = true
	obj.change_animation("hit")
	pass

func _update(_delta: float) -> void:
	#Control jump
	control_jump()
	#Control moving
	control_moving()
	control_attack()
	#If not on floor change to fall
	if not obj.is_on_floor():
		change_state(fsm.states.fall)

func _on_hit_animation_finished() -> void:
	if $"../../Direction/AnimatedSprite2D".animation.find("hit") != -1:
		if !control_moving() and !control_jump():
			change_state(fsm.states.idle)
		elif obj.is_on_floor() and control_moving():
			change_state(fsm.states.walk)
		elif !obj.is_on_floor():
			change_state(fsm.states.fall)
		obj.hit_buffer = false
