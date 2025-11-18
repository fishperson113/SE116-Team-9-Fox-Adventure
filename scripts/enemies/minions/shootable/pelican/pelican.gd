extends ShootableEnemy

#Mô tả:
#Bay qua đi lại trong 1 phạm vi nhất định, độ cao 200 pixel
#Thời gian xuất hiện: 10 giây
#Mỗi 2 giây thả 1 quả cầu cai xuống vị trí mà người chơi đang đứng
#Người chơi chạm vào cầu gai sẽ mất máu theo Spike
#Sau khi hết 10 giây sẽ tự động bay đi mất

@export var bullet_impulse: Vector2 = Vector2(75, -200)

func _ready() -> void:
	super._ready()
	player_detection_raycast.target_position.y = sight

func fire():
	var bullet = _bullet_factory.create() as Bomb
	bullet.set_damage(spike)
	var _bullet_impulse = bullet_impulse
	_bullet_impulse.x *= direction
	bullet.apply_impulse(_bullet_impulse)

func start_shoot() -> void:
	super.start_shoot()
	_movement_speed = 0
