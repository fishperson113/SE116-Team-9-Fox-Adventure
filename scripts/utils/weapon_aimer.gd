class_name WeaponThrower
extends Node

@onready var item_storer: ItemStorer = $"../ItemStorer"
@export var projectile_type: int = 0
var weapon_detail: Resource
var weapon: PackedScene

var max_dir_vector: Vector2 = Vector2(1, -0.1)
var start_dir_vector: Vector2 = Vector2(0.1, -0.1)
var dir_vector: Vector2 = Vector2(0, -0.1)
var dir_change_rate: float = 0.01

var speed: float = 1000
var gravity: float = 300

@onready var trajectory_line: Line2D = $TrajectoryLine
@onready var player: Player = $".."

func _ready() -> void:
	dir_vector = start_dir_vector
	
	weapon = preload("res://scenes/collectibles/items/weapons/weapon_blade.tscn")
	weapon_detail = load("res://data/weapon/blade_throws/weapon_blade_throw.tres")
	pass

func change_weapon() -> void:
	var weapon_temp = weapon.instantiate()
	#weapon_temp.add_general_weapon_properties(weapon_detail)
	speed = weapon_temp.speed
	gravity = weapon_temp.gravity
	
func find_throw_direction(delta: float) -> void:
	if GameManager.blade_count <= 0: 
		return
	
	inspect_direction()
	update_direction()
	trajectory_line.visible = true
	
	trajectory_line.update_trajectory(dir_vector, speed, gravity, delta)

func stop_find_throw_direction() -> void:
	throw_projectile()
	trajectory_line.visible = false

func inspect_direction() -> void:
	if player.direction == -1 and dir_vector.x > 0:
		dir_vector.x = -dir_vector.x
	elif player.direction == 1 and dir_vector.x < 0:
		dir_vector.x = -dir_vector.x
	pass

func update_direction() -> void:
	dir_vector.x += (dir_change_rate * player.direction)
	if dir_vector.x < -max_dir_vector.x:
		dir_vector.x = -max_dir_vector.x
	elif dir_vector.x > max_dir_vector.x:
		dir_vector.x = max_dir_vector.x
	pass

func throw_projectile() -> void:
	print(weapon)
	if weapon != null:
		var weapon_thrown: BaseWeapon = weapon.instantiate()
		weapon_thrown.add_general_weapon_properties(weapon_detail)
		weapon_thrown.global_position = self.get_parent().position
		weapon_thrown.dir = dir_vector
		weapon_thrown.speed = weapon_detail.throw_speed
		weapon_thrown.gravity = weapon_detail.throw_gravity
		weapon_thrown.spin_speed = weapon_detail.spin_speed
		weapon_thrown.set_dealt_damage(weapon_detail.damage)
		weapon_thrown.set_attacker()
		get_tree().current_scene.add_child(weapon_thrown)
		GameManager.remove_blades(1)
		dir_vector = start_dir_vector
	pass
