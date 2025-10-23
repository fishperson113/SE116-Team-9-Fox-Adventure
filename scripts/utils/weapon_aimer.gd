class_name WeaponThrower
extends Node

@onready var item_storer: ItemStorer = $"../ItemStorer"
@export var projectile_type: int = 0
var projectile: PackedScene

@export var dir_vector: Vector2
var max_dir_vector: Vector2 = Vector2(1, 1)
var mouse_dir_vector: Vector2 = Vector2(0, 0)
var mouse_dir_change_rate: float = 0.5
var speed: float
var gravity: float

@onready var trajectory_line: Line2D = $TrajectoryLine
@onready var player: Player = $".."

var max_mouse_still_time = 0.05
var mouse_still_time = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	mouse_still_time += delta
	if mouse_still_time > max_mouse_still_time:
		mouse_dir_vector = Vector2.ZERO
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_dir_vector = Vector2(event.relative.x, event.relative.y)
		mouse_still_time = 0

func change_projectile(pjt_type: int) -> void:
	if pjt_type == -1: 
		projectile = null
		return
	elif pjt_type == 0: projectile = preload("res://scenes/tests/projectile.tscn")
	elif pjt_type == 1: projectile = preload("res://scenes/tests/projectile_blade.tscn")
	var pjt = projectile.instantiate()
	speed = pjt.speed
	gravity = pjt.gravity

func find_throw_direction(delta: float) -> void:
	if !item_storer.is_slot_available(): return
	if !item_storer.is_slot_weapon(): return
	inspect_direction()
	trajectory_line.visible = true
	dir_vector += Vector2(delta * mouse_dir_change_rate * mouse_dir_vector.x, delta * mouse_dir_change_rate * mouse_dir_vector.y)
	
	if dir_vector.x < -max_dir_vector.x:
		dir_vector.x = -max_dir_vector.x
	elif dir_vector.x > max_dir_vector.x:
		dir_vector.x = max_dir_vector.x
	
	if dir_vector.x < 0:
		player.change_direction(-1)
	else:
		player.change_direction(1)
	
	if dir_vector.y < -max_dir_vector.y:
		dir_vector.y = -max_dir_vector.y
	elif dir_vector.y > max_dir_vector.y:
		dir_vector.y = max_dir_vector.y
	
	trajectory_line.update_trajectory(dir_vector, speed, gravity, delta)

func stop_find_throw_direction() -> void:
	if !item_storer.is_slot_available(): return
	if !item_storer.is_slot_weapon(): return
	throw_projectile()
	item_storer.reduce_item()
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
