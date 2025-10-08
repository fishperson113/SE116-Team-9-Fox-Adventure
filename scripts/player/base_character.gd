class_name BaseCharacter
extends CharacterBody2D

## Base character class that provides common functionality for all characters

@export var movement_speed: float = 200.0
@export var gravity: float = 700.0
@export var direction: int = 1

@export var character_type = 0

var hit_buffer: bool = false

var jump_speed: float = 320.0
var fsm: FSM = null
var current_animation = null
var animated_sprite: AnimatedSprite2D = null

var _next_animation = null
var _next_direction: int = 1
var _next_animated_sprite: AnimatedSprite2D = null

@export var jump_step: int = 2
@export var current_jump: int = 0

var maxHealth: float = 250
var currentHealth: float = maxHealth

func _ready() -> void:
	set_animated_sprite($Direction/AnimatedSprite2D)

func _physics_process(delta: float) -> void:
	# Animation
	_check_changed_animation()

	if fsm != null:
		fsm._update(delta)
	# Movement
	_update_movement(delta)
	# Direction
	_check_changed_direction()


func _update_movement(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()
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

func change_player_type(char_type: int) -> void:
	var animation_reset = get_reset_animation_name(current_animation)
	character_type = char_type
	change_animation(animation_reset)

func get_animation_prefix() -> String:
	var char_type: String
	
	if character_type == 0: char_type = ""
	elif character_type == 1: char_type = "hat_"
	elif character_type == 2: char_type = "blade_"
	elif character_type == 3: char_type = "hat_blade_"
	
	return char_type

# Change the direction of the character on the last frame
func change_direction(new_direction: int) -> void:
	_next_direction = new_direction

# Change the animation of the character on the next frame
func change_animation(new_animation: String) -> void:
	if new_animation == "attack" and character_type == 0:
		return
	
	var char_type = get_animation_prefix()
	_next_animation = char_type + new_animation

func get_reset_animation_name(animation_name: String) -> String:
	var next_name: String = animation_name
	var char_type = get_animation_prefix()
	
	next_name = next_name.replace(char_type, "")
	return next_name

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
