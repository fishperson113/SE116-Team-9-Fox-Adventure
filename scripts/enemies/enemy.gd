class_name Enemy
extends CharacterBody2D

## Base character class that provides common functionality for all characters
#Health: Lượng máu mà nhân vật đó có. Tính theo đơn vị HP.
@export var health: float = 0
#Spike: Khi người chơi chạm vào có bị mất máu hay không. Tính theo đơn vị HP.
@export var spike: float = 0
#Sight: Tầm nhìn của quái vật để phát hiện nhân vật của người chơi. Tính theo đơn vị bán kinh Pixel.
@export var sight: float = 100
#Movement Range: Phạm vi di chuyển tối đa của quái. Tính theo đơn vị bán kính Pixel.
@export var movement_range: float = 50
#Movement Speed: Tốc độ di chuyển của nhân vật. Được tính theo đơn vị Pixel / giây
@export var movement_speed: float = 50
#Gravity: Trọng lực của game, được tính bằng Pixel.
@export var gravity: float = 700
#Jump Speed: Tốc độ của cú nhảy, tính bằng Pixel.
@export var jump_speed: float = 320
#Attack Damage: Sát thương của cú đánh. Tính theo đơn vị HP.
@export var attack_damage: float = 50
#Attack Speed: Tốc độ của cú đánh. Tính từ lúc ra đòn cho đến lúc kết thúc đòn đánh. Đơn vị được tính theo Pixel / giây
@export var attack_speed: float = 50

#Jump Height: Tính bằng công thức (Jump Height = Jump Speed ^2 / 2x Gravity)
var jump_height: float = pow(jump_speed, 2.0) / (gravity * 2)
#Air Time: Thời gian trên không, tính bằng công thức (Air Time = Jump Speed / Gravity)
var air_time: float = jump_speed / gravity
var fsm: EnemyFSM = null

#var current_animation = null
#var animated_sprite: AnimatedSprite2D = null
#
#var _next_animation = null
#var _next_animated_sprite: AnimatedSprite2D = null

@onready var _direction_controller = DirectionController.new($Direction)
@onready var _patrol_controller = PatrolController.new(movement_range)
@onready var _animation_controller = AnimationController.new($Direction/AnimatedSprite2D)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	_animation_controller._update(delta)
	
	if fsm != null:
		fsm._update(delta)
	# Movement
	_update_movement(delta)
	_direction_controller._update(delta)

func _update_movement(delta: float) -> void:
	patrol(delta)
	velocity.x = movement_speed * _direction_controller.get_direction()
	velocity.y += gravity * delta
	move_and_slide()
	pass
	
func patrol(delta: float):
	var is_turnaround = _patrol_controller.track_patrol(delta, movement_speed)
	if is_turnaround:
		_direction_controller.turn_around()

func is_hit() -> bool:
	return is_on_wall()

func get_animation_controller() -> AnimationController:
	return _animation_controller
