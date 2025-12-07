extends ShootableEnemy

#Mô tả:
#Đi qua lại trong phạm vi nhất định
#Vừa di chuyển vừa tấn công
#Mỗi giây lại ném 2 quả dừa sang 2 bên theo khoảng cách Movement Distance
#Tốc độ bay của quả dừa sẽ dựa trên Attack Speed
#Đường bay của của dừa sẽ hình vòng cung, bay lên trời rùi mới đáp xuống đất.
#Quả dừa sẽ tự biến mất khi tiếp xúc với mặt đất
#Nếu người chơi chạm vào quả dừa thì sẽ bị mất máu theo Attack Damage

@export var safe_distance: float = 75
@export var bullet_up_impulse: float = -300.0

@onready var _left_factory := $Direction/LeftFactory
@onready var _right_factory := $Direction/RightFactory

var _behind_down_raycast: RayCast2D = null

func _init_ray_cast():
	super._init_ray_cast()
	if has_node("Direction/BehindDownRayCast2D"):
		_behind_down_raycast = $Direction/BehindDownRayCast2D

# Shoot state
func start_shoot() -> void:
	_movement_speed = 0.0
	fire()
	change_animation("shoot")
	fsm.current_state.timer = shoot_time
	pass

func update_shoot(_delta: float) -> void:
	if fsm.current_state.update_timer(_delta):
		fsm.change_state(fsm.states.normal)
	pass

func end_shoot() -> void:
	_shoot_timer.wait_time = randf_range(shoot_cooldown, shoot_cooldown + 1)
	super.end_shoot()
	pass

# Normal state
func update_normal(_delta: float) -> void:
	try_patrol_turn(_delta)
	if is_player_visible():
		stay_focus()
		target(found_player.position)
		avoid_player(found_player.position)
		try_attack()
	else:
		lose_focus()

# Unique constraint
func fire() -> void:
	var leftCoconut = _left_factory.create() as BaseBullet
	var rightCoconut = _right_factory.create() as BaseBullet
	leftCoconut.apply_velocity(Vector2(-direction * attack_speed, bullet_up_impulse))
	rightCoconut.apply_velocity(Vector2(direction * attack_speed, bullet_up_impulse))
	leftCoconut.set_damage(attack_damage)
	rightCoconut.set_damage(attack_damage)

func can_attack() -> bool:
	return _is_ready

func try_attack() -> void:
	if can_attack():
		fsm.change_state(fsm.states.shoot)

func avoid_player(target_position: Vector2) -> int:
	var distance = absf(target_position.x - position.x)
	const tolerance = 5
	if distance >= safe_distance + tolerance:
		_movement_speed = movement_speed
		change_animation("normal")
		return DistanceFeel.FAR
	elif distance <= safe_distance - tolerance and not can_fall_behind():
		_movement_speed = -movement_speed
		change_animation("normal")
		return DistanceFeel.NEAR
	else:
		_movement_speed = 0.0
		change_animation("defend")
		return DistanceFeel.FINE

func stay_focus() -> void:
	turn_chance = 0

func lose_focus() -> void:
	turn_chance = 0.001

func can_fall_behind() -> bool:
	if _behind_down_raycast:
		return not _behind_down_raycast.is_colliding()
	return false
