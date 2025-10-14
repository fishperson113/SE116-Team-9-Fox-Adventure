extends "res://scripts/enemies/barrel/barrel.gd"

@export var shot_delay: float = 0.15 

@onready var shot_delay_timer: Timer = $ShotDelayTimer

var _bullets_to_fire: int = 0

func _ready() -> void:
	super._ready()
	shot_delay_timer.timeout.connect(_on_shot_delay_timer_timeout)
	
func fire() -> void:
	if _bullets_to_fire > 0:
		return

	_bullets_to_fire = 3
	_shoot_one_bullet()

func _shoot_one_bullet() -> void:
	if _bullets_to_fire <= 0:
		return
	
	var bullet := bullet_factory.create() as RigidBody2D
	var shooting_velocity := Vector2(bullet_speed * direction, 0.0)
	bullet.apply_impulse(shooting_velocity)
	
	_bullets_to_fire -= 1
	
	if _bullets_to_fire > 0:
		shot_delay_timer.start(shot_delay)

func _on_shot_delay_timer_timeout() -> void:
	_shoot_one_bullet()
