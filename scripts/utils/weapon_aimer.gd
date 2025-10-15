class_name WeaponThrower
extends Node

@export var projectile: PackedScene

@export var dir_vector: Vector2
var max_dir_vector: Vector2 = Vector2(2, 2)
@export var dir_change_speed: float = 2
@export var speed: float
@export var gravity: float

@onready var trajectory_line: Line2D = $TrajectoryLine
@onready var player: BaseCharacter = $".."

func _process(delta: float) -> void:
	pass

func find_throw_direction(delta: float) -> void:
	inspect_direction()
	trajectory_line.visible = true
	if Input.is_action_pressed("right"):
		dir_vector.x += (delta * dir_change_speed)
	if Input.is_action_pressed("left"):
		dir_vector.x -= (delta * dir_change_speed)
	
	if dir_vector.x < -max_dir_vector.x:
		dir_vector.x = -max_dir_vector.x
	elif dir_vector.x > max_dir_vector.x:
		dir_vector.x = max_dir_vector.x
	
	if dir_vector.x < 0:
		player.change_direction(-1)
	else:
		player.change_direction(1)
	
	if Input.is_action_pressed("up"):
		dir_vector.y -= (delta * dir_change_speed)
	if Input.is_action_pressed("down"):
		dir_vector.y += (delta * dir_change_speed)
	
	if dir_vector.y < -max_dir_vector.y:
		dir_vector.y = -max_dir_vector.y
	elif dir_vector.y > max_dir_vector.y:
		dir_vector.y = max_dir_vector.y
	
	trajectory_line.update_trajectory(dir_vector, speed, gravity, delta)
	print(dir_vector)

func stop_find_throw_direction() -> void:
	throw_projectile()
	trajectory_line.visible = false

func inspect_direction() -> void:
	if player.direction * dir_vector.x < 0:
		dir_vector.x = -dir_vector.x

func throw_projectile() -> void:
	if projectile != null:
		var product: Node2D = projectile.instantiate()
		product.global_position = self.get_parent().position
		product.dir = dir_vector
		product.speed = speed
		product.gravity = gravity
		self.get_parent().get_parent().add_child(product)
	pass
