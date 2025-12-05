class_name WeaponThrower
extends Node

@onready var item_storer: ItemStorer = $"../ItemStorer"
@export var projectile_type: int = 0
var weapon_type: String
var weapon_detail: Resource
var weapon: PackedScene

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

func change_weapon(weapon_type: String, weapon_detail) -> void:
	if weapon_detail is Dictionary:
		weapon_type = "none"
		return
	
	self.weapon_type = weapon_type
	self.weapon_detail = weapon_detail
	if weapon_type == "none": 
		weapon = null
		return
	if weapon_type == "weapon_blade":
		weapon = preload("res://scenes/items/weapons/weapon_blade.tscn")
	var weapon_temp = weapon.instantiate()
	#weapon_temp.add_general_weapon_properties(weapon_detail)
	speed = weapon_temp.speed
	gravity = weapon_temp.gravity
	

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
	item_storer.remove_item(weapon_type, weapon_detail)
	trajectory_line.visible = false

func inspect_direction() -> void:
	if player.direction * dir_vector.x < 0:
		dir_vector.x = -dir_vector.x

func throw_projectile() -> void:
	if weapon != null:
		var weapon_thrown: BaseWeapon = weapon.instantiate()
		weapon_thrown.add_general_weapon_properties(weapon_detail)
		weapon_thrown.global_position = self.get_parent().position
		weapon_thrown.dir = dir_vector
		weapon_thrown.speed = speed
		weapon_thrown.gravity = gravity
		weapon_thrown.set_dealt_damage(weapon_detail.get_damage())
		self.get_parent().get_parent().add_child(weapon_thrown)
	pass
