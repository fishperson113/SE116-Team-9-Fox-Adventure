extends Enemy

#Mô tả:
#Bay qua đi lại trong 1 phạm vi nhất định, độ cao 200 pixel
#Thời gian xuất hiện: 10 giây
#Mỗi 2 giây thả 1 quả cầu cai xuống vị trí mà người chơi đang đứng
#Người chơi chạm vào cầu gai sẽ mất máu theo Spike
#Sau khi hết 10 giây sẽ tự động bay đi mất

@export var _shoot_time: float = 0.5
@export var _shoot_interval: float = 0.5
@export var _attack_cool_down: float = 3.0

var _detect_ray_cast: RayCast2D = null
var _cooldown: float = 0.0

@onready var _bullet_factory := $Direction/BulletFactory

func _ready() -> void:
	super._ready()
	fsm=FSM.new(self,$States,$States/Normal)
	_init_detect_ray_cast()

func _init_detect_ray_cast():
	if has_node("Direction/DetectRayCast2D"):
		_detect_ray_cast = $Direction/DetectRayCast2D

func fire():
	var bullet = _bullet_factory.create() as RigidBody2D
	bullet.set_damage(spike)
	
func get_shoot_time() -> float:
	return _shoot_time

func get_attack_cooldown() -> float:
	return _attack_cool_down

func start_attack_mode() -> void:
	_movement_speed = 0
	_animation_controller.change_animation("attack")
	_cooldown = _shoot_interval

func end_attack_mode() -> void:
	pass

func update_attack_mode(_delta: float) -> void:
	_cooldown -= _delta
	if _cooldown <= 0:
		_cooldown += _shoot_interval
		fire()

func can_attack() -> bool:
	if _detect_ray_cast:
		return _detect_ray_cast.is_colliding()
	return false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_flying_timer_timeout() -> void:
	fsm.change_state(fsm.states.leave)

func start_leave_mode() -> void:
	$CollisionShape2D.disabled = true
