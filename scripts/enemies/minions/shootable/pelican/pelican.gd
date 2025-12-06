extends ShootableEnemy

#Mô tả:
#Bay qua đi lại trong 1 phạm vi nhất định, độ cao 200 pixel
#Thời gian xuất hiện: 10 giây
#Mỗi 2 giây thả 1 quả cầu cai xuống vị trí mà người chơi đang đứng
#Người chơi chạm vào cầu gai sẽ mất máu theo Spike
#Sau khi hết 10 giây sẽ tự động bay đi mất

@export var bullet_impulse: Vector2 = Vector2(75, -200)

@export var left_bound: float = -100
@export var right_bound: float = 100

func _ready() -> void:
	super._ready()
	player_detection_raycast.target_position.y = sight

# Shoot state
func start_shoot() -> void:
	super.start_shoot()
	_movement_speed = 0
	aim()

# Unique constraint
func try_patrol_turn(_delta: float) -> bool:
	if is_touch_wall() or has_reached_bounds() or want_to_turn():
		turn()
		return true
	return false

func has_reached_bounds() -> bool:
	var has_reached_left = (position.x <= left_bound) and (direction == -1)
	var has_reached_right = (position.x >= right_bound) and (direction == 1)
	return has_reached_left or has_reached_right

func aim() -> void:
	if found_player.velocity.x * self.direction < 0:
		turn()

func fire():
	var bullet = _bullet_factory.create() as BaseBullet
	bullet.set_damage(spike)
	var _bullet_impulse = bullet_impulse
	_bullet_impulse.x *= direction
	bullet.apply_velocity(_bullet_impulse)
