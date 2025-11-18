class_name ShootableEnemy
extends StatefulEnemy

enum Direction { LEFT = -1, RIGHT = 1 }

@export var initial_direction: Direction = Direction.LEFT
@export var shoot_time: float = 0.5
@export var shoot_interval: float = 0.5
@export var shoot_cooldown: float = 3.0

var _cooldown: float = 0.0

var _is_ready: bool = true
var _shoot_timer: Timer = null

@onready var _bullet_factory := $Direction/BulletFactory

func _ready() -> void:
	super._ready()
	_init_shoot_state()
	_init_shoot_timer()
	change_direction(initial_direction)
	pass

func _init_shoot_timer():
	if has_node("ShootTimer"):
		_shoot_timer = get_node("ShootTimer")
		_shoot_timer.wait_time = shoot_cooldown
		_shoot_timer.autostart = false
		_shoot_timer.one_shot = true
		_shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _init_shoot_state():
	if has_node("States/Shoot"):
		var _shoot_state := $States/Shoot
		_shoot_state.enter.connect(start_shoot)
		_shoot_state.update.connect(update_shoot)
		_shoot_state.exit.connect(end_shoot)

func fire():
	var bullet = _bullet_factory.create() as RigidBody2D
	bullet.set_damage(spike)

func start_shoot() -> void:
	change_animation("shoot")
	_cooldown = shoot_interval

func end_shoot() -> void:
	_is_ready = false
	_shoot_timer.start()
	pass

func update_shoot(_delta: float) -> void:
	_cooldown -= _delta
	if _cooldown <= 0:
		_cooldown += shoot_interval
		fire()

func can_attack() -> bool:
	if player_detection_raycast and player_detection_raycast.enabled:
		return player_detection_raycast.is_colliding() and _is_ready
	return false

func _on_shoot_timer_timeout():
	_is_ready = true

func update_normal(_delta: float) -> void:
	try_patrol_turn(_delta)
	if randf() < idle_chance:
		fsm.change_state(fsm.states.idle)
	try_attack()
	pass

func update_idle(_delta: float) -> void:
	if randf() < idle_chance:
		fsm.change_state(fsm.states.normal)
	try_attack()
	pass

func try_attack() -> void:
	if can_attack():
		found_player = player_detection_raycast.get_collider() as Player
		fsm.change_state(fsm.states.shoot)
