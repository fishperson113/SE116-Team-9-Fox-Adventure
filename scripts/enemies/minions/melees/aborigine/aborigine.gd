extends StatefulEnemy

#Mô tả:
#Đi qua lại trong phạm vi nhất định
#Vừa di chuyển vừa tấn công
#Mỗi giây lại ném 2 quả dừa sang 2 bên theo khoảng cách Movement Distance
#Tốc độ bay của quả dừa sẽ dựa trên Attack Speed
#Đường bay của của dừa sẽ hình vòng cung, bay lên trời rùi mới đáp xuống đất.
#Quả dừa sẽ tự biến mất khi tiếp xúc với mặt đất
#Nếu người chơi chạm vào quả dừa thì sẽ bị mất máu theo Attack Damage

@export var shoot_time: float = 0.4
@export var shoot_cooldown: float = 1.0

@export var stab_time: float = 0.8
@export var stab_period: float = 0.6
@export var bullet_up_impulse: float = -400.0

var _stab_time: float = 0.0

@onready var _detect_ray_cast := $Direction/DetectRayCast2D
@onready var _stab_box := $Direction/HitArea2D/CollisionShape2D
@onready var _left_factory := $Direction/LeftFactory
@onready var _right_factory := $Direction/RightFactory

func _ready() -> void:
	super._ready()
	_init_hit_area()
	_init_stab_state()
	_init_throw_state()

func _init_hit_area() -> void:
	var hit_area := $Direction/HitArea2D
	hit_area.set_dealt_damage(spike)

func _init_stab_state() -> void:
	if has_node("States/Stab"):
		var state : EnemyState = get_node("States/Stab")
		state.enter.connect(start_stab)
		state.exit.connect(end_stab)
		state.update.connect(update_stab)

func _init_throw_state() -> void:
	if has_node("States/Throw"):
		var state : EnemyState = get_node("States/Throw")
		state.enter.connect(start_throw)

func start_stab() -> void:
	_movement_speed = movement_speed
	_stab_time = stab_period
	change_animation("stab")

func end_stab() -> void:
	_stab_box.disabled = true
	pass

func update_stab(_delta: float) -> void:
	try_patrol_turn(_delta)
	_stab_time -= _delta
	if _stab_time <= 0:
		_stab_box.disabled = false
	pass

func can_stab() -> bool:
	if _detect_ray_cast:
		return _detect_ray_cast.is_colliding()
	return false

func start_throw() -> void:
	_movement_speed = 0.0
	throw()
	change_animation("throw")
	pass
	
func throw() -> void:
	var leftCoconut = _left_factory.create() as RigidBody2D
	var rightCoconut = _right_factory.create() as RigidBody2D
	leftCoconut.apply_impulse(Vector2(-direction * attack_speed, bullet_up_impulse))
	rightCoconut.apply_impulse(Vector2(direction * attack_speed, bullet_up_impulse))
	leftCoconut.set_damage(attack_damage)
	rightCoconut.set_damage(attack_damage)
