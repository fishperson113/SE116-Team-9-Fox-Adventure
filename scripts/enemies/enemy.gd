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

@onready var _direction_controller = DirectionController.new($Direction)
@onready var _patrol_controller = PatrolController.new(movement_range)
@onready var _animation_controller = AnimationController.new($Direction/AnimatedSprite2D)
var _movement_sensor = MovementSensor.new()

# detect player area
var detect_player_area: Area2D = null
var found_player: Player = null

var _is_hurt = false

func _ready() -> void:
	_init_ray_cast()
	_init_detect_player_area()
	_init_hurt_area()
	_init_hit_area()
	fsm = EnemyFSM.new(self, $State, $State/Normal)
	pass

#init ray cast to check wall and fall
func _init_ray_cast():
	if has_node("Direction/FrontRayCast2D"):
		_movement_sensor.set_front_ray_cast($Direction/FrontRayCast2D)
	if has_node("Direction/DownRayCast2D"):
		_movement_sensor.set_down_ray_cast($Direction/DownRayCast2D)

#init detect player area
func _init_detect_player_area():
	if has_node("Direction/DetectPlayerArea2D"):
		detect_player_area = $Direction/DetectPlayerArea2D
		detect_player_area.body_entered.connect(_on_body_entered)
		detect_player_area.body_exited.connect(_on_body_exited)

# init hurt area
func _init_hurt_area():
	if has_node("Direction/HurtArea2D"):
		var hurt_area = $Direction/HurtArea2D
		hurt_area.hurt.connect(_on_hurt_area_2d_hurt)
		
func _init_hit_area():
	if has_node("Direction/HitArea2D"):
		var hit_area = $Direction/HitArea2D
		hit_area.set_dealt_damage(spike)

func _physics_process(delta: float) -> void:
	_animation_controller._update(delta)
	
	if fsm != null:
		fsm._update(delta)
	# Movement
	_update_movement(delta)
	_direction_controller._update(delta)

func _update_movement(delta: float) -> void:
	velocity.x = movement_speed * _direction_controller.get_direction()
	velocity.y += gravity * delta
	move_and_slide()
	pass
	
func try_patrol_turn(delta: float):
	var should_turn_around = _patrol_controller.track_patrol(delta, movement_speed) or _movement_sensor.should_turn_around()
	if should_turn_around:
		_direction_controller.turn_around()

func get_animation_controller() -> AnimationController:
	return _animation_controller

func _on_body_entered(_body: CharacterBody2D) -> void:
	found_player = _body
	_on_player_in_sight(_body.global_position)

func _on_body_exited(_body: CharacterBody2D) -> void:
	found_player = null
	_on_player_not_in_sight()

func _on_hurt_area_2d_hurt(_direction: Vector2, _damage: float) -> void:
	take_damage(_direction, _damage)
	_is_hurt = true
	
# called when player is in sight
func _on_player_in_sight(_player_pos: Vector2):
	pass

# called when player is not in sight
func _on_player_not_in_sight():
	pass

func take_damage(_damage_dir, damage: float) -> void:
	health -= damage

func is_hurt() -> bool:
	return _is_hurt

func on_hurt() -> void:
	if is_hurt():
		fsm.change_state(fsm.states.hurt)

func stop_moving() -> void:
	velocity.x = 0
