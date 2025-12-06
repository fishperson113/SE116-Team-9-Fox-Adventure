class_name Claw
extends BaseBullet

var _launcher: Enemy = null
var _is_returning: bool = false
var _speed: float = 0.0

@onready var _patrol_controller = PatrolController.new(100)

func _ready() -> void:
	super._ready()
	_init_animated_sprite()
	_patrol_controller.set_start_position(position)
	_is_returning = false

func _init_animated_sprite():
	animated_sprite = $Direction/AnimatedSprite2D
	animated_sprite.play()

func _physics_process(delta: float) -> void:
	update_velocity()
	move_and_slide()
	
	if _patrol_controller.track_patrol(position):
		claw_return()
	
	_check_changed_direction()

func update_velocity() -> void:
	velocity.x = absf(velocity.x) * direction

func attach() -> void:
	queue_free()

func claw_return() -> void:
	if not _launcher:
		print("No launcher found")
		return
	
	_is_returning = true
	set_target(_launcher.global_position, _speed)

func set_range(_range: float) -> void:
	_patrol_controller.set_movement_range(_range)

func set_launcher(_l: Enemy) -> void:
	_launcher = _l

func set_target(_target_position: Vector2, _new_speed: float) -> void:
	_speed = _new_speed

	var offset: Vector2 = _target_position - global_position
	var direction_sign: int = sign(offset.x)
	change_direction(direction_sign)

	var vel := offset.normalized() * _speed
	vel.x = absf(vel.x)

	velocity = vel
	rotation = vel.angle() * direction_sign

func is_returning() -> bool:
	return _is_returning

func _on_hitted(_area):
	claw_return()
	pass

func _on_body_entered(_body):
	if _body is not Player:
		claw_return()
