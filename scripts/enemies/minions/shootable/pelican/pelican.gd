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
	_init_leave_state()
	_init_flying_timer()
	_init_screen_notifier()

func _init_screen_notifier():
	var notifier := $VisibleOnScreenNotifier2D
	notifier.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)

func _init_flying_timer():
	var timer := $FlyingTimer
	timer.timeout.connect(_on_flying_timer_timeout)

func _init_leave_state():
	var state : EnemyState = $States/Leave
	state.enter.connect(start_leave)

func fire():
	var bullet = _bullet_factory.create() as Bomb
	bullet.set_damage(spike)

func start_shoot() -> void:
	super.start_shoot()
	_movement_speed = 0

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_flying_timer_timeout() -> void:
	_is_timeout = true

func start_leave() -> void:
	$CollisionShape2D.disabled = true

func can_leave() -> bool:
	return _is_timeout
