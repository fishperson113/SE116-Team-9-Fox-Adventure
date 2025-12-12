extends PlayerState

var dash_multiplier_hor = 1.5
var dash_multiplier_ver = 1.5

func _enter() -> void:
	obj.create_effect("dash")
	sfx_dash.pitch_scale = randf_range(sfx_jump_pitch_min, sfx_jump_pitch_max)
	sfx_dash.play()
	$"../../DashabilityTimer".start()
	obj.current_dash += 1
	obj.current_special_skill_attempt += 1
	obj.skillAttemptChanged.emit(
		obj.max_special_skill_attempt -
		obj.current_special_skill_attempt
		)
	pass

func _update(_delta: float) -> void:
	if obj.special_skill_resolve_timer.is_stopped():
		obj.special_skill_resolve_timer.start()
		
	obj.velocity.x = obj.movement_speed * obj.direction * dash_multiplier_hor
	var up_dir: float = Input.get_action_strength("down") - Input.get_action_strength("up")
	up_dir = sign(up_dir)
	obj.velocity.y = obj.movement_speed * up_dir * dash_multiplier_ver
	obj.move_and_slide()
	
	control_unequip()
	pass

func _on_dashability_timer_timeout() -> void:
	change_state(fsm.states.fall)
	pass # Replace with function body.
