class_name ShootableEnemy
extends Enemy

@export var shoot_time: float = 0.5
@export var shoot_interval: float = 0.5
@export var attack_cooldown: float = 3.0

var _cooldown: float = 0.0

@onready var _detect_ray_cast : RayCast2D = $Direction/DetectRayCast2D
@onready var _bullet_factory := $Direction/BulletFactory
@onready var _shoot_state : EnemyState = $States/Shoot

func _ready() -> void:
	super._ready()
	_shoot_state.enter.connect(start_shoot)
	_shoot_state.update.connect(update_shoot)
	_shoot_state.exit.connect(end_shoot)
	pass

func fire():
	var bullet = _bullet_factory.create() as RigidBody2D
	bullet.set_damage(spike)

func start_shoot() -> void:
	_animation_controller.change_animation("attack")
	_cooldown = shoot_interval

func end_shoot() -> void:
	pass

func update_shoot(_delta: float) -> void:
	_cooldown -= _delta
	if _cooldown <= 0:
		_cooldown += shoot_interval
		fire()

func can_attack() -> bool:
	if _detect_ray_cast:
		return _detect_ray_cast.is_colliding()
	return false
