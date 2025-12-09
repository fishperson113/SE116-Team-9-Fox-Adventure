class_name LootManager
extends Node

var effect_wrapper: PackedScene = null

func _ready() -> void:
	_load_resource()

func _load_resource() -> void:
	effect_wrapper = load("res://scenes/levels/loot_system/loot_physics_body.tscn")

func SpawnLoot(source_node: Node2D):
	var drop_table = _get_closest_drop_data(source_node)
	if not drop_table:
		print("Drop table is not available")
		return
	print("Get the closest drop table successfully: ", drop_table)

	var container_node := get_tree().current_scene
	if container_node.has_node("Collectibles"):
		container_node = get_tree().current_scene.get_node("collectibles") 
	
	var dropables := drop_table.roll()
	for dropable in dropables:
		var b: EffectWrapper = create(dropable)
		b.global_position = source_node.global_position
		container_node.add_child(b)
	print("Drop successfully with these items: ", dropables)

func _get_closest_drop_data(source_node: Node2D) -> DropData:
	var traverse: Node2D = source_node
	while traverse:
		if traverse.has_node("DropData"):
			var data = traverse.get_node("DropData")
			if data is DropData:
				return data

		traverse = traverse.get_parent() as Node2D

	return null

func create(dropable: Node2D) -> RigidBody2D:
	var wrapper: EffectWrapper = effect_wrapper.instantiate()
	wrapper.wrap_up(dropable)
	return wrapper
