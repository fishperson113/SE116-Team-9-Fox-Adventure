extends Minion

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

var _is_player_near: bool = false
var _is_stab_ready: bool = false

var _attack_box: CollisionShape2D = null
var _defend_box: CollisionShape2D = null
var _attack_timer: Timer = null

func _ready() -> void:
	super._ready()
	_init_defend_area()
	_init_attack_timer()
	_init_state("Stab", start_stab, end_stab, update_stab, _on_normal_react)
	_init_state("Defend", start_defend, end_defend, update_defend, _on_normal_react)
	_setup_stab_time()

func _init_defend_area():
	_defend_box = $Direction/Shield/CollisionShape2D

func _init_attack_timer() -> void:
	_attack_timer = $AttackTimer
	_attack_timer.wait_time = attack_cooldown
	_attack_timer.one_shot = true
	_attack_timer.autostart = true
	_attack_timer.timeout.connect(_on_attack_timer_timeout)

func _init_hit_area() -> void:
	super._init_hit_area()
	if _hit_area:
		_hit_area.set_dealt_damage(attack_damage)
		_attack_box = $Direction/HitArea2D/AttackCollisionShape2D

func _setup_stab_time():
	_stab_period = stab_time * 0.75

# Defend state
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
	_defend_box.apply_scale(Vector2.ONE / defend_multiplier)
	pass

# Stab state
func start_stab() -> void:
	fsm.current_state.timer = _stab_period
	change_animation("stab")
	if not animated_sprite.animation_finished.is_connected(_return_to_normal):
		animated_sprite.animation_finished.connect(_return_to_normal)

func end_stab() -> void:
	_attack_box.disabled = true
	_attack_timer.start()
	if animated_sprite.animation_finished.is_connected(_return_to_normal):
		animated_sprite.animation_finished.disconnect(_return_to_normal)
	pass

func update_stab(_delta: float) -> void:
	if fsm.current_state.update_timer(_delta):
		_attack_box.disabled = false
	pass

# Normal state
func update_normal(_delta: float) -> void:
	try_patrol_turn(_delta)
	try_defend()
	pass

# Reaction
func _on_body_entered(_body: CharacterBody2D) -> void:
	super._on_body_entered(_body)
	_is_player_near = true
	pass

func _on_body_exited(_body: CharacterBody2D) -> void:
	super._on_body_exited(_body)
	_is_player_near = false
	pass

# Unique constraint
func can_attack() -> bool:
	return _is_player_near and _is_stab_ready and is_player_visible()

func try_attack() -> void:
	if can_attack():
		_is_stab_ready = false
		fsm.change_state(fsm.states.stab)

func _on_attack_timer_timeout() -> void:
	_is_stab_ready = true

func try_defend() -> void:
	if can_defend():
		target(found_player.position)
		fsm.change_state(fsm.states.defend)

func can_defend() -> bool:
	return is_player_visible()
