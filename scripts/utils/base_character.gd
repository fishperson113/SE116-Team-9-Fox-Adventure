class_name BaseCharacter
extends CharacterBody2D

## Base character class that provides common functionality for all characters

@export var movement_speed: float = 200.0
@export var gravity: float = 700.0
@export var direction: int = 1

@export var character_type = 0

signal healthChanged
signal movementChanging(mover: BaseCharacter)

# These attributes are used to compute externally before collision changing
var old_velocity: Vector2 = Vector2.ZERO
# These attributes are used to apply external forces
var impulse: Vector2 = Vector2.ZERO
var forces: Dictionary = {}
var external_force: Vector2 = Vector2.ZERO
var internal_force: Vector2 = Vector2.ZERO

var jump_speed: float = 320.0
var fsm: FSM = null
var current_animation = null
var animated_sprite: AnimatedSprite2D = null

var _next_animation = null
var _next_direction: int = 1
var _next_animated_sprite: AnimatedSprite2D = null

var maxHealth: float = 3
var currentHealth: float = maxHealth
var input_enabled := true
func _ready() -> void:
	set_animated_sprite($Direction/AnimatedSprite2D)

func _physics_process(delta: float) -> void:
	
	if not input_enabled:
		return
	# Animation
	_check_changed_animation()

	if fsm != null:
		fsm._update(delta)
	# Movement
	if fsm.current_state.name != "launched":
		_update_movement(delta)
	# Direction
	_check_changed_direction()


func _update_movement(delta: float) -> void:
	# save state before collision
	old_velocity = velocity
	
	movementChanging.emit(self)
	
	_calculate_external_force()
	
	velocity.x = internal_force.x + external_force.x + impulse.x
	velocity.y += internal_force.y + external_force.y + impulse.y
	velocity.y += gravity * delta
	move_and_slide()
	
	forces.clear()
	impulse = _dampen(impulse, 0.995)
	pass

func turn_around() -> void:
	if _next_direction != direction:
		return
	_next_direction = -direction

func is_left() -> bool:
	return direction == -1

func is_right() -> bool:
	return direction == 1

func turn_left() -> void:
	_next_direction = -1

func turn_right() -> void:
	_next_direction = 1

func jump() -> void:
	velocity.y = -jump_speed

func stop_move() -> void:
	velocity.x = 0
	velocity.y = 0

# Change the direction of the character on the last frame
func change_direction(new_direction: int) -> void:
	_next_direction = new_direction

# Change the animation of the character on the next frame
func change_animation(new_animation: String) -> void:
	_next_animation = new_animation

# Get the name of the current animation
func get_animation_name() -> String:
	return current_animation

func set_animated_sprite(new_animated_sprite: AnimatedSprite2D) -> void:
	_next_animated_sprite = new_animated_sprite

# Check if the animation or animated sprite has changed and play the new animation
func _check_changed_animation() -> void:
	var need_play: bool = false
	if _next_animation != current_animation:
		current_animation = _next_animation
		need_play = true
	if _next_animated_sprite != animated_sprite:
		if animated_sprite != null:
			animated_sprite.hide()
		animated_sprite = _next_animated_sprite
		animated_sprite.show()
		need_play = true
	if need_play:
		if animated_sprite != null and current_animation != null:
			animated_sprite.play(current_animation)

# Check if the direction has changed and set the new direction
func _check_changed_direction() -> void:
	if _next_direction != direction:
		direction = _next_direction
		_on_changed_direction()
		if direction == -1:
			$Direction.scale.x = -1
		if direction == 1:
			$Direction.scale.x = 1

# On changed direction
func _on_changed_direction() -> void:
	pass

func take_damage(amount: int):
	print(amount)
	print("Health after taking damage: ", currentHealth)
	currentHealth -= amount
	healthChanged.emit()  
	
func heal(amount: int):
	currentHealth += amount
	healthChanged.emit()

func has_force(type: String) -> bool:
	return forces.has(type)

func apply_force(type: String, force: Vector2):
	forces.set(type, force)

func _calculate_external_force():
	external_force = Vector2.ZERO
	for force in forces.values():
		external_force += force

func apply_impulse(_impulse: Vector2):
	impulse += _impulse

func _dampen(force: Vector2, _friction: float) -> Vector2:
	if is_on_wall():
		force.x = 0.0
	if is_on_floor() or is_on_ceiling():
		force.y = 0.0
	force.x = int(force.x * _friction)
	force.y = int(force.y * _friction)
	
	return force
