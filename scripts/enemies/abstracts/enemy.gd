class_name Enemy
extends BaseCharacter

const BLOCK_SIZE: int = 32

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
var _player_detection_count: int = 0
var _has_touched_player: bool = false
var _is_hitted: bool = false

var _front_ray_cast: RayCast2D = null
var _down_ray_cast: RayCast2D = null
var _jump_raycast: RayCast2D = null
var player_detection_raycast: RayCast2D = null
var _detect_obstacle_raycast: RayCast2D = null

var _collision_shape: CollisionShape2D = null
var _hit_area_shape: CollisionShape2D = null
var _hurt_area_shape: CollisionShape2D = null
var _detect_area_shape: CollisionPolygon2D = null

var _detect_player_area: Area2D = null
var _near_sense_area: Area2D = null
var _hit_area: HitArea2D = null
var _hurt_area: HurtArea2D = null

func _ready() -> void:
	super._ready()
	
	_init_components()
	_init_stats()
	_init_behaviors()
	
	_setup_jump_raycast()
	_setup_front_raycast()
	_setup_down_raycast()

func _init_components() -> void:
	_init_animated_sprite()
	_init_ray_cast()
	_init_detect_player_area()
	_init_near_sense_area()
	_init_hurt_area()
	_init_hit_area()
	_init_collision_shape()

func _init_stats() -> void:
	jump_speed = 235
	currentHealth = health
	var r = get_size().y / BLOCK_SIZE
	_jump_speed = r * jump_speed

func _init_behaviors() -> void:
	_patrol_controller = PatrolController.new(movement_range)

func _setup_front_raycast() -> void:
	if _front_ray_cast:
		_front_ray_cast.target_position.x = 0.0
		_front_ray_cast.target_position.y = get_size().y
		_front_ray_cast.position.x = get_size().x / 2 + 1
		_front_ray_cast.position.y = - get_size().y / 2

func _setup_down_raycast() -> void:
	if _down_ray_cast:
		_down_ray_cast.target_position.x = 0.0
		_down_ray_cast.target_position.y = get_size().y
		_down_ray_cast.position.x = get_size().x / 2
		_down_ray_cast.position.y = get_size().y / 2

func _setup_jump_raycast():
	if _jump_raycast:
		var t = jump_speed / gravity
		var sy = - gravity * t * t / 2 + jump_speed * t
		var sx = movement_speed * t
		_jump_raycast.target_position = Vector2(-sx, -sy)
		_jump_raycast.position.x = sx
		_jump_raycast.position.y = - get_size().y / 2
		#_jump_raycast.target_position = Vector2.ONE * -BLOCK_SIZE
		#_jump_raycast.position.x = BLOCK_SIZE / 2 + get_size().x / 2
		#var r = ceilf(get_size().y / BLOCK_SIZE)
		#_jump_raycast.position.y = -(BLOCK_SIZE * r - get_size().y / 2)
	pass

func _init_animated_sprite():
	if has_node("Direction/AnimatedSprite2D"):
		animated_sprite = $Direction/AnimatedSprite2D

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
	if has_node("DetectObstacleRayCast2D"):
		_detect_obstacle_raycast = $DetectObstacleRayCast2D

#init detect player area
func _init_detect_player_area():
	if has_node("Direction/DetectPlayerArea2D"):
		_detect_player_area = $Direction/DetectPlayerArea2D
		_detect_area_shape = _detect_player_area.get_node("CollisionPolygon2D")
		_detect_player_area.body_entered.connect(_on_body_entered)
		_detect_player_area.body_exited.connect(_on_body_exited)

func _init_near_sense_area():
	if has_node("Direction/NearSenseArea2D"):
		_near_sense_area = $Direction/NearSenseArea2D
		_near_sense_area.body_entered.connect(_on_near_sense_body_entered)
		_near_sense_area.body_exited.connect(_on_near_sense_body_exited)

func _init_hit_area():
	if has_node("Direction/HitArea2D"):
		_hit_area = $Direction/HitArea2D
		_hit_area.set_dealt_damage(spike)
		_hit_area.set_attacker(self)
		_hit_area.hitted.connect(_on_hit_area_2d_hitted)
		_hit_area.area_entered.connect(_on_hit_area_2d_area_entered)
		_hit_area.area_exited.connect(_on_hit_area_2d_area_exited)
		_hit_area_shape = _hit_area.get_node("NormalCollisionShape2D")

# init hurt area
func _init_hurt_area():
	if has_node("Direction/HurtArea2D"):
		_hurt_area = $Direction/HurtArea2D
		_hurt_area_shape = _hurt_area.get_node("CollisionShape2D")
		_hurt_area.hurt.connect(_on_hurt_area_2d_hurt)

func _init_collision_shape():
	if has_node("CollisionShape2D"):
		_collision_shape = $CollisionShape2D

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	aim_raycast_at_player()

func _update_movement(delta: float) -> void:
	velocity.x = _movement_speed * direction
	velocity.y += gravity * delta
	move_and_slide()
	pass
	
func try_patrol_turn(_delta: float) -> bool:
	if try_jump():
		return false
	if is_touch_wall() or is_can_fall() or want_to_turn():
		turn()
		return true
	return false

func turn() -> void:
	turn_around()

func try_jump() -> bool:
	if not is_touch_wall() or not is_on_floor():
		return false
	
	# Jump if there are no obstacles above
	if not _jump_raycast.is_colliding():
		jump()
		return true
	# Jump onto player
	if _jump_raycast.get_collider() is Player:
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
	remember_player(_body)
	_on_player_in_sight(_body.global_position)

func _on_body_exited(_body: CharacterBody2D) -> void:
	forget_player()
	_on_player_not_in_sight()

func _on_near_sense_body_entered(_body) -> void:
	remember_player(_body)

func _on_near_sense_body_exited(_body) -> void:
	forget_player()
	pass

func _on_hurt_area_2d_hurt(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	var _context = HurtBehaviorInput.new(_attacker, _direction, _damage)
	fsm.current_state._react(_context)

func _on_hit_area_2d_hitted(_body) -> void:
	_is_hitted = true
	pass

func _on_hit_area_2d_area_entered(_area: Area2D):
	_has_touched_player = true
	pass

func _on_hit_area_2d_area_exited(_area: Area2D):
	_has_touched_player = false
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

func is_alive() -> bool:
	return currentHealth > 0.0

func get_size() -> Vector2:
	if _collision_shape:
		return _collision_shape.shape.size
	return Vector2.ZERO

func want_to_turn() -> bool:
	return randf() < turn_chance

func take_damage_behavior(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	take_damage(int(_damage))
	bounce_off(_direction)
	target(_attacker.position)
	fsm.change_state(fsm.states.hurt)

func bounce_off(_direction: Vector2) -> void:
	_movement_speed = movement_speed * _direction.x * direction

func remember_player(_player: Player) -> void:
	_player_detection_count += 1
	if found_player:
		return
	found_player = _player

func forget_player() -> void:
	_player_detection_count = max(_player_detection_count - 1, 0)
	if _player_detection_count > 0:
		return
	found_player = null

func aim_raycast_at_player() -> void:
	if not _detect_obstacle_raycast:
		return
	if not found_player:
		unaim()
		return
	_detect_obstacle_raycast.target_position = found_player.position - position

func unaim() -> void:
	if not _detect_obstacle_raycast:
		return
	_detect_obstacle_raycast.target_position = Vector2.ZERO

func is_player_visible() -> bool:
	if not _detect_obstacle_raycast:
		return false
	if not found_player:
		return false
	return _detect_obstacle_raycast.get_collider() is Player

func is_close(target: Vector2, tolerance: float) -> bool:
	return target.distance_to(position) <= tolerance

func hold_distance(_target_position: Vector2, _safe_distance: float, _tolerance: float) -> void:
	var distance = _target_position.distance_to(position)
	if distance >= _safe_distance + _tolerance:
		move_forward()
	elif distance <= _safe_distance - _tolerance:
		move_backward()
	else:
		stop_move()

func move_forward() -> void:
	_movement_speed = movement_speed

func move_backward() -> void:
	_movement_speed = -movement_speed

func stop_move() -> void:
	_movement_speed = 0.0

func hold_distance_from_player() -> bool:
	if not _collision_shape or not found_player:
		move_forward()
		return false
		
	var _area = _collision_shape.shape
	if _hit_area_shape:
		_area = _hit_area_shape.shape
	elif _hurt_area_shape:
		_area = _hurt_area_shape.shape
	
	hold_distance(found_player.position, _area.size.x / 2, 5)
	return true

func manage_attack_spacing() -> void:
	if _has_touched_player:
		move_backward()
	else:
		move_forward()

func is_on_direction(_target_position: Vector2) -> bool:
	return (_target_position - position).x * direction >= 0

func set_combat_collision(flag: bool) -> void:
	_hurt_area_shape.disabled = not flag
	_hit_area_shape.disabled = not flag

func clear_area_collision(_area: Area2D) -> void:
	_area.collision_layer = 0
	_area.collision_mask = 0

func target(_position: Vector2) -> void:
	if _compute_target_direction(_position) != direction:
		turn()

func _compute_target_direction(_position: Vector2) -> int:
	var target_direction = -1
	if _position.x > position.x:
		target_direction = 1
	return target_direction

func try_recover() -> bool:
	if is_alive():
		fsm.change_state(fsm.states.normal)
		return true
	fsm.change_state(fsm.states.dead)
	return false

func _compute_anim_speed(_anim_name: String, duration: float) -> float:
	if not animated_sprite:
		print("Animation srpite has not existed, ", animated_sprite)
		return 0.0
	var frame_count = animated_sprite.sprite_frames.get_frame_count(_anim_name)
	return frame_count / duration
