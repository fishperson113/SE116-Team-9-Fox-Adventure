extends CharacterBody2D

#@export var min_speed: float = 200.0
#@export var max_speed: float = 350.0

@export var min_size: float = 30
@export var max_size: float = 90

@export var base_speed: float = 150.0
@export var base_gravity: float = 3500.0

@export var bounce_up: float = 0.2

@export var time_to_live: float = 5

var _speed: float = 0
var _old_speed: float = 0
var _gravity: float = 0

var _is_dissolved: bool = false

var _anim_player: AnimationPlayer = null

func _ready() -> void:
	_init_size()
	_init_live_timer()
	_init_anim_player()

func _init_anim_player():
	_anim_player = $AnimationPlayer
	_anim_player.animation_finished.connect(_on_animation_finished)

func _init_live_timer():
	var timer: Timer = $Timer
	timer.one_shot = true
	timer.wait_time = time_to_live
	timer.timeout.connect(_on_timeout)
	timer.start()

func _init_size() -> void:
	var collision_box : CollisionShape2D = $CollisionShape2D
	var collision_shape := collision_box.shape
	var sprite: Sprite2D = $Sprite2D
	var hit_area: HitArea2D = $HitArea2D
	
	var _size = randf_range(min_size, max_size)
	var multiplier = _size / collision_shape.size.x
	
	collision_box.apply_scale(Vector2(multiplier, multiplier))
	sprite.apply_scale(Vector2(multiplier, multiplier))
	hit_area.apply_scale(Vector2(multiplier, multiplier))
	_gravity = base_gravity * multiplier
	_speed = base_speed / multiplier
	
	hit_area.set_dealt_damage(0)

func _physics_process(delta: float) -> void:
	_old_speed = velocity.y
	
	velocity.x = _speed
	velocity.y += _gravity * delta
	move_and_slide()

	bounce()

func bounce():
	if is_on_floor():
		velocity.y = -_old_speed * bounce_up

func _on_timeout():
	start_disolve()

func start_disolve():
	if not _is_dissolved:
		_is_dissolved = true
		_anim_player.play("dissolving")

func _on_animation_finished(_anim_name: String):
	queue_free()
