class_name PackedSceneFactory

var _owner_node: Node = null

func _init(owner_node: Node) -> void:
	_owner_node = owner_node

func create(_packed_scene: PackedScene, container_node_name: String, _position: Vector2):
	if not _packed_scene:
		print("Packed scened is undefined")
		return
	
	var scene: Node2D = _packed_scene.instantiate()
	scene.global_position = _position
	
	var container_node = _owner_node.get_tree().current_scene.find_child(container_node_name)
	# Default container node is the root node
	if not container_node:
		print("Cannot find the container node with name: ", container_node_name)
		container_node = _owner_node.get_tree().current_scene
	
	container_node.add_child(scene)
	print("Scene has been successfully created")
	return scene
