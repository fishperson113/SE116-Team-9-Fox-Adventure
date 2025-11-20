class_name Spawner
extends Node2D

@export var objects: Array[PackedScene] = []
@export var spawn_count: int = 1
@export var group: String = "Obstacles"

func execute():
	massive_spawn(spawn_count, objects)

func massive_spawn(total: int, resource: Array):
	if resource.is_empty():
		return
	
	for i in range(0, total):
		call_deferred("spawn", resource.pick_random())

func spawn(packed_scene: PackedScene):
	var spawned_object = packed_scene.instantiate()
	if not spawned_object:
		print("Not found object %s" % packed_scene)
		return
	
	var container = find_parent("Stage").find_child(group)
	if not container:
		print("Not found container %s" % group)
		return
	
	container.add_child(spawned_object)
	set_up_object(spawned_object)
	return spawned_object

func set_up_object(spawned_object: Node2D):
	spawned_object.position = position
