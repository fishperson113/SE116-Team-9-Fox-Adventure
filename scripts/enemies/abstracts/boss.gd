class_name Boss
extends StatefulEnemy

@export_group("Skill setting")
@export var max_stamina: int = 4
@export var rest_time: float = 3.0
@export var skill_cooldown: float = 2.0

@export_group("Intelligence setting")
@export var close_range: float = 300.0
@export var misbehave_chance: float = 0.25

var _stamina
var _short_range_skills: Array = []
var _far_range_skills: Array = []

func _ready() -> void:
	super._ready();
	_init_skill_set()
	_init_state("Rest", start_rest, end_rest, update_rest, _on_normal_react)

func _init_skill_set():
	rest()

func get_skill():
	var is_close = is_player_close()
	if randf() <= misbehave_chance:
		is_close = not is_close
		
	if is_close:
		return _short_range_skills.pick_random()
	return _far_range_skills.pick_random()

func use_stamina() -> void:
	_stamina += 1

func is_exhausted() -> bool:
	return _stamina >= max_stamina

func rest() -> void:
	_stamina = 0

func start_normal() -> void:
	_movement_speed = movement_speed
	change_animation("normal")
	fsm.current_state.timer = skill_cooldown

func update_normal(_delta: float) -> void:
	if not is_player_visible():
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

func _return_to_rest():
	fsm.change_state(fsm.states.rest)

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

func is_player_close() -> bool:
	if not found_player:
		return false
	return is_close(found_player.position, close_range)

# Reaction
func _on_normal_react(input: BehaviorInput) -> void:
	if input is HurtBehaviorInput:
		take_damage(input.damage_taken)
		if not is_alive():
			fsm.change_state(fsm.states.dead)
	pass
