extends CharacterBody2D

var _velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO
@export var speed: float
@export var gravity: float

func _ready() -> void:
	_velocity = dir * speed

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	
	var collision = move_and_collide(_velocity * delta)
	if not collision: return
	
	queue_free()
