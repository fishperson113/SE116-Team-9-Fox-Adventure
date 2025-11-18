class_name ShootableEnemy
extends StatefulEnemy

enum Direction { LEFT = -1, RIGHT = 1 }

@export var initial_direction: Direction = Direction.LEFT
@export var shoot_time: float = 0.5
@export var shoot_interval: float = 0.5
@export var shoot_cooldown: float = 3.0

var _cooldown: float = 0.0

@onready var _bullet_factory := $Direction/BulletFactory
var _shoot_state : EnemyState = null

func _ready() -> void:
	super._ready()
	_init_shoot_state()
	change_direction(initial_direction)
	pass

func _init_shoot_state():
	if has_node("States/Shoot"):
		_shoot_state = $States/Shoot
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
	pass

func update_shoot(_delta: float) -> void:
	_cooldown -= _delta
	if _cooldown <= 0:
		_cooldown += shoot_interval
		fire()

func can_attack() -> bool:
	if player_detection_raycast:
		return player_detection_raycast.is_colliding()
	return false
