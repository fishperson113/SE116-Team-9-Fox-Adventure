@tool
class_name Spawner
extends Node2D

@export var enemies: Array[PackedScene] = []

@export var width: float:
	set(value):
		width = value
		$DebugOx.target_position.x = value

@export var height: float:
	set(value):
		height = value
		$DebugOy.target_position.y = -value * 1.5

@export var melee_spawn: int = 2
@export var range_spawn: int = 2

var _melees: Array[int]
var _ranges: Array[int]

# This will only be called when you create, delete, or paste a resource.
# You will not get an update when tweaking properties of it.
func _on_resource_set():
	print("My resource was set!")
	
func _ready():
	classify()
	pass

func classify():
	for i in range(0, enemies.size()):
		var live = await enemies[i].instantiate()
		if live.is_in_group("range"):
			_ranges.push_back(i)
		else:
			_melees.push_back(i)

func spawn(index):
	var spawned_enemy = enemies[index].instantiate() as Enemy
	
	var container = find_parent("Stage").find_child("Bullets")
	container.add_child(spawned_enemy)
	
	random_position(spawned_enemy)
	pass

func bias_spawn():
	massive_spawn(melee_spawn, _melees)
	massive_spawn(range_spawn, _ranges)

func massive_spawn(total: int, resource: Array[int]):
	for i in range(0, total):
		call_deferred("spawn", resource.pick_random())
		#spawn(resource.pick_random())

func random_position(spawned_enemy: Enemy):
	spawned_enemy.position.x = position.x + randf_range(0, width)
	
	var y_offset = randf_range(height, height * 1.5)
	if not spawned_enemy.is_in_group("fly"):
		var size = spawned_enemy.get_size()
		y_offset = size.y / 2

	spawned_enemy.position.y = position.y - y_offset
