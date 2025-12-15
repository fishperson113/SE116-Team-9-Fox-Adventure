class_name ShootableEnemy
extends Minion

enum Direction { LEFT = -1, RIGHT = 1 }

@export var initial_direction: Direction = Direction.LEFT
@export var shoot_time: float = 0.5
@export var shoot_interval: float = 0.5
@export var shoot_cooldown: float = 3.0

var _cooldown: float = 0.0

var _is_ready: bool = true
var _shoot_timer: Timer = null

var _bullet_factory: Node2DFactory = null

func _ready() -> void:
	super._ready()
	_init_state("Shoot", start_shoot, end_shoot, update_shoot, _on_normal_react)
	_init_shoot_timer()
	_init_bullet_factory()
	change_direction(initial_direction)
	pass

func _init_bullet_factory():
	if has_node("Direction/BulletFactory"):
		_bullet_factory = $Direction/BulletFactory

func _init_shoot_timer():
	if has_node("ShootTimer"):
		_shoot_timer = get_node("ShootTimer")
		_shoot_timer.wait_time = shoot_cooldown
		_shoot_timer.autostart = false
		_shoot_timer.one_shot = true
		_shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func fire():
	var bullet = _bullet_factory.create() as RigidBody2D
	bullet.set_damage(spike)

# Shoot state
func start_shoot() -> void:
	change_animation("shoot")
	_cooldown = shoot_interval
	fsm.current_state.timer = shoot_time

func end_shoot() -> void:
	_is_ready = false
	_shoot_timer.start()
	pass

func update_shoot(_delta: float) -> void:
	_cooldown -= _delta
	if _cooldown <= 0:
		_cooldown += shoot_interval
		fire()
	if fsm.current_state.update_timer(_delta):
		fsm.change_state(fsm.states.normal)

func can_attack() -> bool:
	return is_player_visible() and _is_ready

func _on_shoot_timer_timeout():
	_is_ready = true

func update_normal(_delta: float) -> void:
	try_patrol_turn(_delta)
	try_attack()
	pass

func try_attack() -> void:
	if can_attack():
		found_player = player_detection_raycast.get_collider() as Player
		fsm.change_state(fsm.states.shoot)

func is_player_visible() -> bool:
	if player_detection_raycast and player_detection_raycast.enabled:
		return player_detection_raycast.is_colliding()
	return super.is_player_visible()
