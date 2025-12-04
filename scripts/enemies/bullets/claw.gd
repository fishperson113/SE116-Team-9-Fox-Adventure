class_name Claw
extends BaseBullet

var _launcher: Enemy = null
var _is_returning: bool = false

@onready var _patrol_controller = PatrolController.new(100)

func _ready() -> void:
	super._ready()
	_init_animated_sprite()
	_patrol_controller.set_start_position(position.x)
	_is_returning = false

func _init_animated_sprite():
	animated_sprite = $Direction/AnimatedSprite2D
	animated_sprite.play()

func _process(_delta: float) -> void:
	update_velocity()
	move_and_slide()
	
	if _patrol_controller.track_patrol(position.x, direction):
		claw_return()
	
	_check_changed_direction()

func update_velocity() -> void:
	velocity.x = abs(velocity.x) * direction

func attach() -> void:
	queue_free()

func claw_return() -> void:
	if not _launcher:
		print("No launcher found")
		return
	
	if _is_returning:
		return
	
	_is_returning = true
	if _launcher.position.x < position.x:
		turn_left()
	else:
		turn_right()

func set_range(_range: float) -> void:
	_patrol_controller.set_movement_range(_range)

func set_direction(_direction: int) -> void:
	change_direction(_direction)

func set_launcher(_l: Enemy) -> void:
	_launcher = _l

func is_returning() -> bool:
	return _is_returning

func _on_body_entered(_body):
	# Do nothing
	pass

func _on_hitted(_area):
	claw_return()
	pass
