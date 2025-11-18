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
@export var movement_range: float = 500
#Attack Damage: Sát thương của cú đánh. Tính theo đơn vị HP.
@export var attack_damage: float = 50
#Attack Speed: Tốc độ của cú đánh. Tính từ lúc ra đòn cho đến lúc kết thúc đòn đánh. Đơn vị được tính theo Pixel / giây
@export var attack_speed: float = 50
#+ Thêm biến để chọn kiểu phát hiện người chơi
@export var use_raycast_detection: bool = false

@export var turn_chance: float = 0.001

#Jump Height: Tính bằng công thức (Jump Height = Jump Speed ^2 / 2x Gravity)
var jump_height: float = pow(jump_speed, 2.0) / (gravity * 2)
#Air Time: Thời gian trên không, tính bằng công thức (Air Time = Jump Speed / Gravity)
var air_time: float = jump_speed / gravity
var found_player: Player = null

var _movement_speed: float = movement_speed
var _jump_speed: float = jump_speed

var _patrol_controller: PatrolController = null

var _front_ray_cast: RayCast2D = null
var _down_ray_cast: RayCast2D = null
var _jump_raycast: RayCast2D = null
var player_detection_raycast: RayCast2D = null

var _collision_shape: CollisionShape2D = null
var _hit_area_shape: CollisionShape2D = null

var _detect_player_area: Area2D = null
var _near_sense_area: Area2D = null
var _hit_area: HitArea2D = null

func _ready() -> void:
	super._ready()
	_init_ray_cast()
	_init_detect_player_area()
	_init_near_sense_area()
	_init_hurt_area()
	_init_hit_area()
	_init_collision_shape()
	_patrol_controller = PatrolController.new(movement_range)
	jump_speed = 235
	_jump_speed = jump_speed
	pass

#init ray cast to check wall and fall
func _init_ray_cast():
	if has_node("Direction/FrontRayCast2D"):
		_front_ray_cast = $Direction/FrontRayCast2D
	if has_node("Direction/DownRayCast2D"):
		_down_ray_cast = $Direction/DownRayCast2D
	#+ Khởi tạo raycast phát hiện người chơi
	if has_node("Direction/PlayerDetectionRayCast"):
		player_detection_raycast = $Direction/PlayerDetectionRayCast
	if has_node("Direction/JumpRayCast2D"):
		_jump_raycast = $Direction/JumpRayCast2D
		_jump_raycast.target_position.y = -25
		_jump_raycast.target_position.x = -16

#init detect player area
func _init_detect_player_area():
	if has_node("Direction/DetectPlayerArea2D"):
		_detect_player_area = $Direction/DetectPlayerArea2D
		_detect_player_area.body_entered.connect(_on_body_entered)
		_detect_player_area.body_exited.connect(_on_body_exited)

func _init_near_sense_area():
	if has_node("Direction/NearSenseArea2D"):
		_near_sense_area = $Direction/NearSenseArea2D

func _init_hit_area():
	if has_node("Direction/HitArea2D"):
		_hit_area = $Direction/HitArea2D
		_hit_area.set_dealt_damage(spike)
		_hit_area.hitted.connect(_on_hit_area_2d_hitted)
		_hit_area_shape = _hit_area.get_node("NormalCollisionShape2D")

# init hurt area
func _init_hurt_area():
	if has_node("Direction/HurtArea2D"):
		var hurt_area = $Direction/HurtArea2D
		hurt_area.hurt.connect(_on_hurt_area_2d_hurt)
		
func _init_collision_shape():
	if has_node("CollisionShape2D"):
		_collision_shape = $CollisionShape2D

func _update_movement(delta: float) -> void:
	velocity.x = _movement_speed * direction
	velocity.y += gravity * delta
	move_and_slide()
	pass
	
func try_patrol_turn(_delta: float) -> bool:
	#var is_reach_limit = _patrol_controller.track_patrol(position.x, direction)
	if try_jump():
		return false
	if is_touch_wall() or is_can_fall() or want_to_turn():
		turn()
		return true
	return false

func turn() -> void:
	_patrol_controller.set_start_position(position.x)
	turn_around()

func try_jump() -> bool:
	if not is_touch_wall():
		return false
	
	_jump_raycast.global_position = _front_ray_cast.get_collision_point()
	_jump_raycast.global_position.x -= direction * _jump_raycast.target_position.x / 2
	_jump_raycast.global_position.y -= 2
	_jump_raycast.force_raycast_update()
	if not _jump_raycast.is_colliding() or _jump_raycast.get_collider() is Player:
		jump()
		return true

	return false

func jump() -> void:
	if is_on_floor():
		velocity.y = -_jump_speed

func is_touch_wall() -> bool:
	if _front_ray_cast and _front_ray_cast.enabled:
		return _front_ray_cast.is_colliding()
	return false

func is_can_fall() -> bool:
	if _down_ray_cast and _down_ray_cast.enabled:
		return not _down_ray_cast.is_colliding() and is_on_floor()
	return false

func _on_body_entered(_body: CharacterBody2D) -> void:
	found_player = _body
	_on_player_in_sight(_body.global_position)

func _on_body_exited(_body: CharacterBody2D) -> void:
	found_player = null
	_on_player_not_in_sight()

func _on_hurt_area_2d_hurt(_direction: Vector2, _damage: float) -> void:
	take_damage(_damage)
	fsm.current_state.take_damage()

func _on_hit_area_2d_hitted(_body) -> void:
	pass
	
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
	if(_detect_player_area != null):
		_detect_player_area.get_node("CollisionShape2D").disabled = false

func disable_check_player_in_sight() -> void:
	if(_detect_player_area != null):
		_detect_player_area.get_node("CollisionShape2D").disabled = true

func take_damage(amount: int) -> void:
	health -= amount

func is_alive() -> bool:
	return health > 0.0

func get_size() -> Vector2:
	if _collision_shape:
		return _collision_shape.shape.size
	return Vector2.ZERO

func want_to_turn() -> bool:
	return randf() < turn_chance
