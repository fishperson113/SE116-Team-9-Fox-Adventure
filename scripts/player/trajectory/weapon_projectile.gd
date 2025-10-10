extends CharacterBody2D

var _velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO
@export var speed: float
@export var gravity: float

func _ready() -> void:
	_velocity = dir * speed

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	move_and_collide(_velocity * delta)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.queue_free()
	queue_free()
	pass # Replace with function body.
