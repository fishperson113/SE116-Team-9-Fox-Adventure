class_name Enemy
extends BaseCharacter

## Base character class that provides common functionality for all characters
#Health: Lượng máu mà nhân vật đó có. Tính theo đơn vị HP.
@export var health: float = 0
#Spike: Khi người chơi chạm vào có bị mất máu hay không. Tính theo đơn vị HP.
@export var spike: float = 0
#Sight: Tầm nhìn của quái vật để phát hiện nhân vật của người chơi. Tính theo đơn vị bán kinh Pixel.
@export var sight: float = 100
#Movement Range: Phạm vi di chuyển tối đa của quái. Tính theo đơn vị bán kính Pixel.
@export var movement_range: float = 50
##Movement Speed: Tốc độ di chuyển của nhân vật. Được tính theo đơn vị Pixel / giây
#@export var movement_speed: float = 50
##Gravity: Trọng lực của game, được tính bằng Pixel.
#@export var gravity: float = 700
##Jump Speed: Tốc độ của cú nhảy, tính bằng Pixel.
#@export var jump_speed: float = 320
#Attack Damage: Sát thương của cú đánh. Tính theo đơn vị HP.
@export var attack_damage: float = 50
#Attack Speed: Tốc độ của cú đánh. Tính từ lúc ra đòn cho đến lúc kết thúc đòn đánh. Đơn vị được tính theo Pixel / giây
@export var attack_speed: float = 50
@export var hurt_time: float = 0.4

#+ Thêm biến để chọn kiểu phát hiện người chơi
@export var use_raycast_detection: bool = false

#Jump Height: Tính bằng công thức (Jump Height = Jump Speed ^2 / 2x Gravity)
var jump_height: float = pow(jump_speed, 2.0) / (gravity * 2)
#Air Time: Thời gian trên không, tính bằng công thức (Air Time = Jump Speed / Gravity)
var air_time: float = jump_speed / gravity
#var fsm: EnemyFSM = null
# detect player area
var detect_player_area: Area2D = null
var found_player: Player = null
#+ Thêm tham chiếu đến RayCast phát hiện người chơi
var player_detection_raycast: RayCast2D = null

var _movement_speed: float = movement_speed
var _direction_controller: DirectionController = null
var _patrol_controller: PatrolController = null
var _animation_controller: AnimationController = null
var _movement_sensor: MovementSensor = null

func _ready() -> void:
	_init_controller()
	_init_sensor()
	_init_ray_cast()
	_init_detect_player_area()
	_init_hurt_area()
	_init_hit_area()
	pass

func _init_controller():
	_direction_controller = DirectionController.new($Direction)
	_patrol_controller = PatrolController.new(movement_range)
	_animation_controller = AnimationController.new($Direction/AnimatedSprite2D)

func _init_sensor():
	_movement_sensor = MovementSensor.new()

#init ray cast to check wall and fall
func _init_ray_cast():
	if has_node("Direction/FrontRayCast2D"):
		_movement_sensor.set_front_ray_cast($Direction/FrontRayCast2D)
	if has_node("Direction/DownRayCast2D"):
		_movement_sensor.set_down_ray_cast($Direction/DownRayCast2D)
	#+ Khởi tạo raycast phát hiện người chơi
	if has_node("Direction/PlayerDetectionRayCast"):
		player_detection_raycast = $Direction/PlayerDetectionRayCast

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
	velocity.x = _movement_speed * _direction_controller.get_direction()
	velocity.y += gravity * delta
	move_and_slide()
	pass
	
func try_patrol_turn(delta: float):
	var is_touch_wall = _movement_sensor.is_touch_wall()
	var is_can_fall = _movement_sensor.is_can_fall() and is_on_floor()
	var is_reach_limit = _patrol_controller.track_patrol(position.x, _direction_controller.get_direction())
	var should_turn_around = is_touch_wall or is_can_fall or is_reach_limit
	if should_turn_around:
		_direction_controller.turn_around()
		_patrol_controller.set_start_position(position.x)

func _on_body_entered(_body: CharacterBody2D) -> void:
	found_player = _body
	_on_player_in_sight(_body.global_position)

func _on_body_exited(_body: CharacterBody2D) -> void:
	found_player = null
	_on_player_not_in_sight()

func _on_hurt_area_2d_hurt(_direction: Vector2, _damage: float) -> void:
	take_damage(_direction, _damage)
	fsm.current_state.take_damage()
	
# called when player is in sight
func _on_player_in_sight(_player_pos: Vector2):
	pass

# called when player is not in sight
func _on_player_not_in_sight():
	pass

#+ Thêm hàm kiểm tra người chơi bằng RayCast từ Code 2
func is_player_in_sight_by_raycast() -> bool:
	if player_detection_raycast == null:
		return false
		
	player_detection_raycast.force_raycast_update()
	
	if player_detection_raycast.is_colliding() and player_detection_raycast.get_collider() is Player:
		found_player = player_detection_raycast.get_collider()
		return true
	else:
		found_player = null
		return false

#+ Thêm các hàm bật/tắt vùng dò tìm từ Code 2
func enable_check_player_in_sight() -> void:
	if(detect_player_area != null):
		detect_player_area.get_node("CollisionShape2D").disabled = false

func disable_check_player_in_sight() -> void:
	if(detect_player_area != null):
		detect_player_area.get_node("CollisionShape2D").disabled = true

func take_damage(_damage_dir, damage: float) -> void:
	health -= damage

func is_alive() -> bool:
	return health > 0.0

func start_normal_mode() -> void:
	_movement_speed = movement_speed
	
	_animation_controller.change_animation("normal")

func end_normal_mode() -> void:
	pass

func update_normal_mode(_delta: float) -> void:
	try_patrol_turn(_delta)

func start_hurt_mode() -> void:
	_movement_speed = 0.0
	
	_animation_controller.change_animation("hurt")

func end_hurt_mode() -> void:
	pass

func update_hurt_mode(_delta: float) -> void:
	pass

func start_dead_mode() -> void:
	queue_free()

func end_dead_mode() -> void:
	pass

func update_dead_mode(_delta: float) -> void:
	pass
