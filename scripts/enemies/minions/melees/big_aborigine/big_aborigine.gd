extends StatefulEnemy

#Mô tả:
#Đứng im tại chỗ
#Khi phát hiện người chơi trong phạm vi Sight sẽ sử dụng khiên chắn trước mặt theo hướng của người chơi.
#Cứ 2 giây sẽ hướng phía người chơi và tấn công bằng giáo, phạm vi tấn công bằng Sight, 1 lần gây sát thương bằng Attack Damage và tốc độ bằng Attack Speed
#Khiên không thể bị phá vỡ
#Quái vật này chỉ có thể bị tấn công từ phía sau.
@export var stab_time: float = 0.8
@export var attack_cooldown: float = 2.0
@export var defend_multiplier: float = 1.5

var _stab_period: float = 0.0

var _stab_time: float = 0.0
var _is_player_near: bool = false
var _is_stab_ready: bool = false

var _attack_box: CollisionShape2D = null
var _defend_box: CollisionShape2D = null
var _attack_timer: Timer = null

func _ready() -> void:
	super._ready()
	_init_hit_area()
	_init_defend_area()
	_init_attack_timer()
	_init_stab_state()
	_init_defend_state()

func _init_defend_area():
	_defend_box = $Direction/Shield/CollisionShape2D

func _init_attack_timer() -> void:
	_attack_timer = $AttackTimer
	_attack_timer.wait_time = attack_cooldown
	_attack_timer.one_shot = true
	_attack_timer.autostart = true
	_attack_timer.timeout.connect(_on_attack_timer_timeout)

func _init_hit_area() -> void:
	var hit_area := $Direction/HitArea2D
	_attack_box = $Direction/HitArea2D/AttackCollisionShape2D
	hit_area.set_dealt_damage(attack_damage)

func _init_stab_state() -> void:
	if has_node("States/Stab"):
		var state : EnemyState = get_node("States/Stab")
		state.enter.connect(start_stab)
		state.exit.connect(end_stab)
		state.update.connect(update_stab)
		
		_stab_period = stab_time * 0.75

func _init_defend_state() -> void:
	if has_node("States/Defend"):
		var state : EnemyState = get_node("States/Defend")
		state.enter.connect(start_defend)
		state.update.connect(update_defend)
		state.exit.connect(end_defend)

func can_defend() -> bool:
	return found_player != null
	
func start_defend():
	_movement_speed = 0.0
	_defend_box.apply_scale(Vector2(defend_multiplier, defend_multiplier))
	change_animation("defend")
	pass

func update_defend(_delta: float):
	try_attack()
	if not can_defend():
		fsm.change_state(fsm.states.normal)
		return
	target(found_player.position)
	pass

func end_defend() -> void:
	_defend_box.apply_scale(Vector2(1/defend_multiplier, 1/defend_multiplier))
	pass

func _on_attack_timer_timeout() -> void:
	_is_stab_ready = true

func start_stab() -> void:
	_stab_time = _stab_period
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

func update_normal(_delta: float) -> void:
	try_patrol_turn(_delta)
	try_defend()
	pass

func try_defend() -> void:
	if can_defend():
		target(found_player.position)
		fsm.change_state(fsm.states.defend)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	#print(fsm.current_state)

func _on_body_entered(_body: CharacterBody2D) -> void:
	_is_player_near = true
	pass

func _on_body_exited(_body: CharacterBody2D) -> void:
	_is_player_near = false
	pass

func _on_near_sense_body_exited(_body) -> void:
	if _body is Player:
		found_player = null
	pass

func can_attack() -> bool:
	return _is_player_near and _is_stab_ready

func try_attack() -> void:
	if can_attack():
		_is_stab_ready = false
		fsm.change_state(fsm.states.stab)
