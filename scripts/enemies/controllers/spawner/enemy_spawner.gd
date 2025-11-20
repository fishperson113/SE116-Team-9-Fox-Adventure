@tool
class_name EnemySpawner
extends CompositeSpawner

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

func _ready():
	super._ready()
	classify()
	pass

func classify():
	for i in range(0, objects.size()):
		var live = objects[i].instantiate()
		if live.is_in_group("range"):
			_ranges.push_back(i)
		else:
			_melees.push_back(i)

# Spawns melee and ranged units using their respective spawn functions.
# `massive_spawn` handles bulk spawning, taking a spawn function and a list of unit data.
# - melee_spawn is applied to all items in _melees
# - range_spawn is applied to all items in _ranges
func execute():
	massive_spawn(melee_spawn, _melees)
	massive_spawn(range_spawn, _ranges)

func massive_spawn(total: int, resource: Array):
	if resource.is_empty():
		return
	
	for i in range(0, total):
		call_deferred("spawn", objects[resource.pick_random()])

func set_up_object(object):
	random_position(object)
	pass

func random_position(spawned_enemy: Enemy):
	spawned_enemy.position.x = position.x + randf_range(0, width)
	
	var y_offset = randf_range(height, height * 1.5)
	if not spawned_enemy.is_in_group("fly"):
		var size = spawned_enemy.get_size()
		y_offset = size.y / 2

	spawned_enemy.position.y = position.y - y_offset
