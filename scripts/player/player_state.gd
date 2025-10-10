class_name PlayerState
extends FSMState

func _enter() -> void:
	pass

func _exit() -> void:
	pass

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	var dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var is_moving: bool = abs(dir) > 0.1
	if is_moving and obj.fsm.current_state != fsm.states.throwing:
		dir = sign(dir)
		obj.change_direction(dir)
		obj.velocity.x = obj.movement_speed * dir
		if obj.is_on_floor():
			change_state(fsm.states.walk)
		return true
	else:
		obj.velocity.x = 0
	return false

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	#If jump is pressed change to jump state and return true
	var is_jumping= Input.is_action_just_pressed("jump")
	if (is_jumping and obj.current_jump<obj.jump_step):
		obj.velocity.y = -obj.jump_speed
		change_state(fsm.states.jump)
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

func control_hit() -> bool:
	var is_hit = Input.is_action_just_pressed("hit")
	if is_hit:
		change_state(fsm.states.hit)
		return true
	return false

func control_defeat() -> bool:
	var is_defeat = Input.is_action_just_pressed("defeat")
	if is_defeat:
		change_state(fsm.states.defeat)
		return true
	return false

func control_throwing(delta: float) -> bool:
	if Input.is_action_pressed("throw"):
		obj.weapon_thrower.find_throw_direction(delta)
		change_state(fsm.states.throwing)
		return true
	elif Input.is_action_just_released("throw"):
		obj.weapon_thrower.stop_find_throw_direction()
	return false

func deduct_health(amount: float) -> bool:
	obj.currentHealth -= amount
	print(obj.currentHealth)
	
	if (obj.currentHealth > 0):
		return true
	obj.currentHealth = 0
	return false
