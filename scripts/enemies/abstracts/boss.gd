class_name Boss
extends StatefulEnemy

@export var max_stamina: int = 4
@export var cooldown: float = 1.0
@export var rest_time: float = 2.0

var _stamina
var _skill_set = []

func _ready() -> void:
	super._ready();
	_init_skill_set()
	_init_rest_state()

func _init_rest_state() -> void:
	if has_node("States/Rest"):
		var state : EnemyState = get_node("States/Rest")
		state.enter.connect(start_rest)
		state.exit.connect(end_rest)
		state.update.connect(update_rest)

func _init_skill_set():
	rest()

func get_skill():
	return _skill_set.pick_random()

func use_stamina() -> void:
	_stamina += 1

func is_exhausted() -> bool:
	return _stamina >= max_stamina

func rest() -> void:
	_stamina = 0

func start_normal() -> void:
	_movement_speed = movement_speed
	change_animation("normal")
	fsm.current_state.timer = cooldown

func update_normal(_delta: float) -> void:
	if not found_player:
		return
	target(found_player.position)
	if is_exhausted():
		fsm.change_state(fsm.states.rest)
	if fsm.current_state.update_timer(_delta):
		use_stamina()
		fsm.change_state(get_skill())
	pass

func start_rest() -> void:
	_movement_speed = 0.0
	change_animation("rest")
	fsm.current_state.timer = rest_time

func end_rest() -> void:
	rest()

func update_rest(_delta) -> void:
	if fsm.current_state.update_timer(_delta):
		_return_to_normal()

func _return_to_normal():
	fsm.change_state(fsm.states.normal)

func _on_near_sense_body_exited(_body) -> void:
	if _body is Player:
		found_player = null
	pass

func compute_speed(_t: float, _dis: Vector2, _gra: float):
	var speed := Vector2.ZERO
	speed.x = _dis.x / _t
	speed.y = -1 * (0.5 * _t * _gra + _dis.y / _t)
	return speed

func compute_shot_speed(from: Vector2, to: Vector2, strength: float):
	var normalized := (to - from).normalized()
	return normalized * strength
