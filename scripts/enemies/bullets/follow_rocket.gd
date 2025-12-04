class_name FollowRocket
extends BaseBullet

@export var tolerance := Vector2(10, 5)
@export var min_setup_time: float = 0.5
@export var max_setup_time: float = 1.0

var _launcher: Enemy = null
var _speed := Vector2.ZERO

var _target: BaseCharacter = null
var _step: Array[Vector2]
var _step_cursor: int = 0

func _ready() -> void:
	super._ready()
	fsm = FSM.new(self, $States, $States/Prepare)
	_init_prepare_state()
	_init_detect_state()
	_init_attack_state()
	prepare_vertical_attack()

func _init_attack_state():
	if has_node("States/Attack"):
		var state = get_node("States/Attack")
		state.enter.connect(start_attack)
		state.exit.connect(end_attack)
		state.update.connect(update_attack)

func _init_detect_state():
	if has_node("States/Detect"):
		var state = get_node("States/Detect")
		state.enter.connect(start_detect)
		state.exit.connect(end_detect)
		state.update.connect(update_detect)

func _init_prepare_state():
	if has_node("States/Prepare"):
		var state = get_node("States/Prepare")
		state.enter.connect(start_prepare)
		state.exit.connect(end_prepare)
		state.update.connect(update_prepare)

func set_launcher(_l: Enemy):
	self._launcher = _l

func set_target(_t: BaseCharacter):
	_target = _t

func apply_velocity(fire_velocity: Vector2) -> void:
	_speed = fire_velocity.abs()
	velocity *= _speed

func _process(_delta: float) -> void:
	rotation = velocity.angle() + PI / 2

func prepare_vertical_attack():
	_step = [Vector2.UP]
	
func start_prepare() -> void:
	_step_cursor = 0
	fsm.current_state.timer = randf_range(min_setup_time, max_setup_time)
	pass

func end_prepare() -> void:
	pass

func update_prepare(_delta: float) -> void:
	if fsm.current_state.update_timer(_delta):
		_step_cursor += 1
		fsm.current_state.timer = randf_range(min_setup_time, max_setup_time)
	if _step_cursor >= _step.size():
		fsm.change_state(fsm.states.detect)
		return
	velocity = _step[_step_cursor] * _speed
	pass

func start_detect() -> void:
	velocity = turn(velocity)
	pass

func end_detect() -> void:
	pass

func update_detect(_delta: float) -> void:
	if not _target:
		return
		
	var dis = _target.position - position
	velocity = (dis * velocity.abs()).normalized() * _speed
	if abs(dis.x) <= tolerance.x or abs(dis.y) <= tolerance.y:
		fsm.change_state(fsm.states.attack)

func start_attack() -> void:
	if not _target:
		return

	var dis = _target.position - position
	velocity = turn(velocity)
	velocity = (dis * velocity.abs()).normalized() * _speed

func end_attack() -> void:
	pass

func update_attack(_delta: float) -> void:
	pass

func turn(_t: Vector2):
	if _t.dot(Vector2.LEFT) == 0:
		return Vector2.LEFT
	return Vector2.UP
