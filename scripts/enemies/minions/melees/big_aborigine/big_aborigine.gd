extends StatefulEnemy

#Mô tả:
#Đứng im tại chỗ
#Khi phát hiện người chơi trong phạm vi Sight sẽ sử dụng khiên chắn trước mặt theo hướng của người chơi.
#Cứ 2 giây sẽ hướng phía người chơi và tấn công bằng giáo, phạm vi tấn công bằng Sight, 1 lần gây sát thương bằng Attack Damage và tốc độ bằng Attack Speed
#Khiên không thể bị phá vỡ
#Quái vật này chỉ có thể bị tấn công từ phía sau.

var stab_time: float = sight / attack_speed
var stab_period: float = stab_time * 3 / 4

var _stab_time: float = 0.0

@onready var _attack_box := $Direction/HitArea2D/CollisionShape2D
@onready var _attack_timer := $AttackTimer

@onready var _detect_ray_cast: RayCast2D = $Direction/DetectRayCast2D

func _ready() -> void:
	super._ready()
	_init_hit_area()
	_init_detect_ray_cast()
	_init_attack_timer()
	_init_stab_state()
	_init_defend_state()

func _init_attack_timer() -> void:
	var timer := $AttackTimer
	timer.timeout.connect(_on_attack_timer_timeout)

func _init_hit_area() -> void:
	var hit_area := $Direction/HitArea2D
	hit_area.set_dealt_damage(attack_damage)

func _init_detect_ray_cast():
	_detect_ray_cast.target_position.x = sight

func _init_stab_state() -> void:
	if has_node("States/Stab"):
		var state : EnemyState = get_node("States/Stab")
		state.enter.connect(start_stab)
		state.exit.connect(end_stab)
		state.update.connect(update_stab)

func _init_defend_state() -> void:
	if has_node("States/Defend"):
		var state : EnemyState = get_node("States/Defend")
		state.enter.connect(start_defend)

func can_defend() -> bool:
	if _detect_ray_cast:
		return _detect_ray_cast.is_colliding()
	return false
	
func start_defend():
	change_animation("defend")
	pass

func _on_attack_timer_timeout() -> void:
	fsm.change_state(fsm.states.stab)

func start_stab() -> void:
	_stab_time = stab_period
	change_animation("stab")

func end_stab() -> void:
	_attack_box.disabled = true
	_attack_timer.start()
	pass

func update_stab(_delta: float) -> void:
	_stab_time -= _delta
	if _stab_time <= 0:
		_attack_box.disabled = false
	pass
