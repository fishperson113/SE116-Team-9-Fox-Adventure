class_name FollowRocket
extends BaseRocket

@export var turn_angle: float = PI / 2
@export var turn_chance: float = 0.1

var _launcher: Enemy = null
var _speed := Vector2(1, 1)
var _target: BaseCharacter = null

func _ready() -> void:
	super._ready()
	set_up_attack()

func set_launcher(_l: Enemy):
	self._launcher = _l

func set_target(_t: BaseCharacter):
	_target = _t

func apply_velocity(fire_velocity: Vector2) -> void:
	_speed = fire_velocity.abs()
	velocity = velocity.normalized() * _speed

func set_up_attack():
	var direction = Vector2.from_angle(randf_range(-turn_angle / 2, turn_angle / 2) - PI / 2)
	velocity = direction

func _process(delta: float) -> void:
	super._process(delta)
	redirect(delta)

func redirect(delta: float):
	var _distance = _target.position - position
	var _current_angle = abs(_distance.angle_to(velocity))
	if _current_angle <= turn_angle:
		var _accepted_angle = _compute_angular_sweep(_distance, delta)
		_try_rushing(_current_angle, _accepted_angle, _distance)
	else:
		_try_turn_toward_target(_distance)

func _try_rushing(_current_angle: float, _accepted_angle: float, _distance: Vector2):
	if turn_angle - _current_angle <= _accepted_angle:
		velocity = _distance.normalized() * velocity.length()

func _compute_angular_sweep(_distance: Vector2, _delta: float):
	var _half_step = velocity * _delta / 2
	var _upper_bound = _distance + _half_step
	var _lower_bound = _distance - _half_step
	return absf(_upper_bound.angle_to(_lower_bound))

func _try_turn_toward_target(_distance: Vector2):
	if randf() <= turn_chance:
		var rotated_angle = randf_range(0, turn_angle)
		velocity = velocity.rotated(rotated_angle * sign(_distance.x))
