extends Minion

#Mô tả:
#Đi qua đi lại trong 1 phạm vi nhất định
#Nếu phát hiện người chơi trong Sight sẽ cuộn tròn và lăn về phía người chơi, tăng 50% tốc di chuyển khi đang lăn
#Chạm vào người chơi sẽ dừng lại 1 giây trước khi tiếp tục hành động tiếp.
#Người chơi chạm vào sẽ bị mất máu theo Spike
#Không được di chuyển quá Movement Range cho phép
#Không có khả năng tấn công

@export var attack_speed_multiplier: float = 1.5

@export var prepare_time: float = 0.4
@export var eager_time: float = 1
@export var stun_time: float = 0.5

@onready var _roll_box: CollisionShape2D = $Direction/HitArea2D/RollCollisionShape2D
@onready var _normal_box: CollisionShape2D = $Direction/HitArea2D/NormalCollisionShape2D

var _sight: float = 0
var _player_pos: Vector2 = Vector2.ZERO
var _is_hitted: bool = false

func _ready() -> void:
	super._ready()
	_init_prepare_state()
	_init_attack_state()
	_init_eager_state()
	_init_stun_state()
	_sight = _front_ray_cast.position.x

func _init_eager_state() -> void:
	if has_node("States/Eager"):
		var state : EnemyState = get_node("States/Eager")
		state.enter.connect(start_eager)
		state.exit.connect(end_eager)
		state.update.connect(update_eager)

func _init_attack_state() -> void:
	if has_node("States/Attack"):
		var state : EnemyState = get_node("States/Attack")
		state.enter.connect(start_attack)
		state.exit.connect(end_attack)
		state.update.connect(update_attack)

func _init_prepare_state() -> void:
	if has_node("States/Prepare"):
		var state : EnemyState = get_node("States/Prepare")
		state.enter.connect(start_prepare)
		state.exit.connect(end_prepare)
		state.update.connect(update_prepare)

func _init_stun_state() -> void:
	if has_node("States/Stun"):
		var state : EnemyState = get_node("States/Stun")
		state.enter.connect(start_stun)
		state.exit.connect(end_stun)
		state.update.connect(update_stun)

func _on_hit_area_2d_hitted(_body) -> void:
	_is_hitted = true
	pass

func get_stun_time() -> float:
	return stun_time

# Normal
func update_normal(_delta: float) -> void:
	super.update_normal(_delta)
	if is_player_visible():
		fsm.change_state(fsm.states.prepare)

# Attack state
func start_attack() -> void:
	_movement_speed = movement_speed * attack_speed_multiplier
	
	_normal_box.disabled = true
	_roll_box.disabled = false
	
	change_animation("attack")

func end_attack() -> void:
	_movement_speed = movement_speed
	
	_roll_box.disabled = true
	_normal_box.disabled = false
	pass

func update_attack(_delta: float) -> void:
	try_jump()
	if is_player_visible():
		remember_player_position()
		return
	if not is_close(_player_pos, 5) and is_on_direction(_player_pos):
		return
	fsm.change_state(fsm.states.stun)
	#if _is_hitted or not try_jump() and is_on_wall() and is_on_floor():
		#_is_hitted = false
		#fsm.change_state(fsm.states.stun)
	pass

# Prepare state
func start_prepare() -> void:
	_movement_speed = movement_speed / attack_speed_multiplier
	change_animation("prepare")
	fsm.current_state.timer = prepare_time
	pass

func end_prepare() -> void:
	pass
	
func update_prepare(_delta: float) -> void:
	remember_player_position()
	if fsm.current_state.update_timer(_delta):
		fsm.change_state(fsm.states.attack)
	pass

# Eager state
func start_eager() -> void:
	start_attack()
	fsm.current_state.timer = eager_time
	pass

func end_eager() -> void:
	end_attack()
	pass
	
func update_eager(_delta: float) -> void:
	update_attack(_delta)
	#if can_attack() and _compute_target_direction(found_player.position) != direction:
		#fsm.change_state(fsm.states.stun)
	#if can_attack():
		#fsm.current_state.timer = eager_time
	#elif fsm.current_state.update_timer(_delta):
		#fsm.change_state(fsm.states.stun)
	pass

# Stun state
func start_stun() -> void:
	_movement_speed = movement_speed / attack_speed_multiplier
	change_animation("stun")
	fsm.current_state.timer = stun_time
	pass

func end_stun() -> void:
	#target(_player_pos)
	if not found_player:
		turn_around()
	pass
	
func update_stun(_delta: float) -> void:
	if fsm.current_state.update_timer(_delta):
		fsm.change_state(fsm.states.normal)
	pass

func remember_player_position() -> void:
	if found_player:
		_player_pos = found_player.position
