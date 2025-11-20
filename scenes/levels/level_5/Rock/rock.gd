extends CharacterBody2D

@export var min_speed: float = 50
@export var max_speed: float = 75

var _speed: float = 0

func _ready() -> void:
	_speed = randf_range(min_speed, max_speed)

func _physics_process(delta: float) -> void:
	velocity.x = _speed
	move_and_slide()
