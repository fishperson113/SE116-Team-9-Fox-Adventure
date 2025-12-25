class_name EffectWrapper
extends RigidBody2D

signal finish

const CHILD_NAME: String = "Core"
const MAX_SPEED: float = 800

func _ready() -> void:
	sleeping_state_changed.connect(_on_sleep_change)
	await get_tree().physics_frame
	play_effect()

func _physics_process(delta):
	if linear_velocity.length() > MAX_SPEED:
		linear_velocity = linear_velocity.normalized() * MAX_SPEED

func wrap_up(node: Node2D) -> void:
	var parent = node.get_parent()
	if parent:
		parent.remove_child(node)
	
	var old_pos: Vector2 = node.global_position
	add_child(node)
	
	if parent:
		parent.add_child(self)

	# These modifcations should be here because the effect of add and remove child
	node.name = CHILD_NAME
	node.global_position = old_pos

func unwrap() -> void:
	var node: Node2D = null
	if not has_node(CHILD_NAME):
		return

	node = get_node(CHILD_NAME)
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	
	var old_pos: Vector2 = node.global_position
	remove_child(node)
	
	if parent:
		parent.add_child(node)

	# These modifcations should be here because the effect of add and remove child
	node.global_position = old_pos

func _on_sleep_change() -> void:
	finish.emit()
	call_deferred("dissolve")

func dissolve() -> void:
	unwrap()
	queue_free()

func play_effect() -> void:
	var vertical_speed: float = randf_range(-200, -400)
	var horizontal_speed: float = randf_range(-100, 100)
	apply_impulse(Vector2(horizontal_speed, vertical_speed))
