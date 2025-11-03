extends ShootableEnemy

#Mô tả:
#Bay qua đi lại trong 1 phạm vi nhất định, độ cao 200 pixel
#Thời gian xuất hiện: 10 giây
#Mỗi 2 giây thả 1 quả cầu cai xuống vị trí mà người chơi đang đứng
#Người chơi chạm vào cầu gai sẽ mất máu theo Spike
#Sau khi hết 10 giây sẽ tự động bay đi mất

var _is_timeout = false

func _ready() -> void:
	super._ready()
	fsm=FSM.new(self,$States,$States/Normal)

func fire():
	var bullet = _bullet_factory.create() as RigidBody2D
	bullet.set_damage(spike)

func start_shoot() -> void:
	super.start_shoot()
	_movement_speed = 0

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_flying_timer_timeout() -> void:
	_is_timeout = true

func start_leave_mode() -> void:
	$CollisionShape2D.disabled = true

func can_leave() -> bool:
	return _is_timeout
