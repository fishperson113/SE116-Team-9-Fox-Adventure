class_name PlayerState
extends FSMState

var smoke = preload("res://scenes/levels/island/objects/smoke/smoke.tscn")
var is_prepare_throw_playing: bool = false

func _enter() -> void:
	pass

func _exit() -> void:
	pass

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	#if control_throwing(get_process_delta_time()):
	#	obj.internal_force.x = 0
	#	return false
		
	var dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var is_moving: bool = abs(dir) > 0.1
	if is_moving:
		dir = sign(dir)
		obj.change_direction(dir)
		obj.internal_force.x = obj.movement_speed * dir
		if obj.is_on_floor():
			if fsm.current_state == fsm.states.throwing:
				obj.change_animation("walk")
			else:
				change_state(fsm.states.walk)
				obj.current_dash = 0
		return true
	else:
		obj.internal_force.x = 0
	return false
	
func control_special_ability() -> bool:
	if not Input.is_action_just_pressed("special_attack"):
		return false
	var skill_activated = false
	match obj.current_skill_id:
		"dash":
			if obj.current_dash < obj.max_dash and obj.current_special_skill_attempt < obj.max_special_skill_attempt:
				change_state(fsm.states.dash)
				obj.weapon_thrower.change_weapon("weapon_blade")
				skill_activated = true
				
		"wide_attack":
			if obj.current_special_skill_attempt < obj.max_special_skill_attempt:
				change_state(fsm.states.wideattack)
				obj.weapon_thrower.change_weapon("weapon_blade")
				skill_activated = true
		
		"fireball_attack":
			if obj.current_special_skill_attempt < obj.max_special_skill_attempt:
				obj.weapon_thrower.change_weapon("weapon_fireball")
				obj.weapon_thrower.throw_projectile()
				obj.current_special_skill_attempt += 1
				AudioManager.play_sound("player_fireball_shoot")
				obj.skillAttemptChanged.emit(
					obj.max_special_skill_attempt -
					obj.current_special_skill_attempt
				)
				if obj.special_skill_resolve_timer.is_stopped():
					obj.special_skill_resolve_timer.start()
				skill_activated = true
				
	if skill_activated:
		obj.on_use_skill_durability()
		return true
	return false
#Control jumping
#Return true if jumping
func control_jump() -> bool:
	if !Input.is_action_just_pressed("jump"):
		return false
		
	if obj.is_on_floor():
		obj.current_jump = 0
	
	if obj.current_jump >= obj.jump_step:
		return false
	
	AudioManager.play_sound("player_jump", 10)
	obj.velocity.y = -obj.jump_speed
	change_state(fsm.states.jump)
	obj.current_jump += 1
	return true

func control_attack() -> bool:
	for char_type in [0, 1]:
		if obj.character_type == char_type: return false
		
	var is_attack = Input.is_action_just_pressed("attack")
	if is_attack:
		change_state(fsm.states.attack)
		return true
	return false

func control_throwing(delta: float) -> bool:
	if Input.is_action_pressed("throw"):
		if not is_prepare_throw_playing and GameManager.blade_count > 0:
			AudioManager.play_sound("player_prepare_throw")
			is_prepare_throw_playing = true
		obj.weapon_thrower.change_weapon("weapon_blade")
		if GameManager.blade_count <= 0:
			return false
		
		obj.weapon_thrower.find_throw_direction(delta)
		change_state(fsm.states.throwing)
		return true
	elif Input.is_action_just_released("throw"):
		is_prepare_throw_playing = false
		if GameManager.blade_count <= 0:
			return false
		AudioManager.play_sound("player_blade_throw")
		obj.weapon_thrower.stop_find_throw_direction()
	return false

func take_damage(damage) -> void:
	#Player take damage
	#Player die if health is 0 and change to dead state
	#Player hurt if health is not 0 and change to hurt state
	obj.take_damage(damage)
	if(obj.currentHealth<=0):
		change_state(fsm.states.defeat)
	else:
		change_state(fsm.states.hit)
	return
	
func add_jump_effect(pos: Vector2):
	var jump_fx = smoke.instantiate()
	jump_fx.position = pos
	add_child(jump_fx)
	
func control_unequip():
	pass
