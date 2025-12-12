class_name PlayerState
extends FSMState

var smoke = preload("res://scenes/levels/island/objects/smoke/smoke.tscn")

#Sound effects
@onready var sfx_jump: AudioStreamPlayer = $"../../SFX/Jump"

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
				skill_activated = true
				
	if skill_activated:
		obj.on_use_skill_durability()
		return true
	return false
#Control jumping
#Return true if jumping
func control_jump() -> bool:
	#If jump is pressed change to jump state and return true
	var is_jumping= Input.is_action_just_pressed("jump")
	if (is_jumping and obj.current_jump<obj.jump_step):
		obj.velocity.y = -obj.jump_speed
		change_state(fsm.states.jump)
		sfx_jump.play()
		#var starting = obj.get_parent()
		#if starting.has_method("add_smoke_effect"):
			#starting.add_smoke_effect(obj.global_position)
		if obj.is_on_floor():
			add_jump_effect(Vector2(obj.position.x, obj.position.y + 8))
		obj.current_jump+=1
		return true
	return false

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
		obj.weapon_thrower.change_weapon("weapon_blade")
		if GameManager.blade_count <= 0:
			return false
		
		obj.weapon_thrower.find_throw_direction(delta)
		change_state(fsm.states.throwing)
		return true
	elif Input.is_action_pressed("special_attack"):
		if obj.current_skill_id != "fireball_attack" or obj.current_special_skill_attempt >= obj.max_special_skill_attempt:
			return false
		
		obj.weapon_thrower.change_weapon("weapon_fireball")
		obj.weapon_thrower.find_throw_direction(delta)
		change_state(fsm.states.throwing)
		return true
	elif Input.is_action_just_released("throw"):
		if GameManager.blade_count <= 0:
			return false
		obj.weapon_thrower.stop_find_throw_direction()
	elif Input.is_action_just_released("special_attack"):
		if obj.current_skill_id != "fireball_attack" or obj.current_special_skill_attempt >= obj.max_special_skill_attempt:
			return false
		obj.weapon_thrower.stop_find_throw_direction()
		obj.current_special_skill_attempt += 1
		obj.skillAttemptChanged.emit(
			obj.max_special_skill_attempt -
			obj.current_special_skill_attempt
			)
		if obj.special_skill_resolve_timer.is_stopped():
			obj.special_skill_resolve_timer.start()
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
