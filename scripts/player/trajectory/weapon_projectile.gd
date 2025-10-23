extends CharacterBody2D
class_name Projectile

var _velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO
var speed: float
var gravity: float
@export var spin_speed: float #tốc độ quay được tính bằng độ

func _init() -> void:
	speed = 180
	gravity = 250
	spin_speed = 20

func _ready() -> void:
	_velocity = dir * speed

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	move_and_collide(_velocity * delta)
	rotate(deg_to_rad(spin_speed))

func _on_body_entered(body: Node2D) -> void:
	queue_free()
	pass # Replace with function body.
