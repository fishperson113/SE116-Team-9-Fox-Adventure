extends ShootableEnemy

#-	Mô tả:
#Đứng im tại chỗ không thể di chuyển
#Khi phát hiện Player trong Sight sẽ bắn 3 viên đạn nước liên tiếp về phía người chơi.
#Mỗi viên sẽ có tốc độ bay bằng Attack Speed và sát thương bằng Attack Damage
#Cooldown 3 giây (bất kể người chơi có ở trong Sight hay không).

func _ready() -> void:
	super._ready()
	player_detection_raycast.target_position.x = sight

# Normal state
func update_normal(_delta: float) -> void:
	try_attack()
	pass

# Unique constraint
func fire():
	var bullet = _bullet_factory.create() as BaseBullet
	bullet.set_damage(attack_damage)
	bullet.apply_velocity(Vector2(attack_speed * direction, 0.0))
	bullet.set_gravity(0.0)
