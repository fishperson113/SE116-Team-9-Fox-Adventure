@tool
class_name CompositeSpawner
extends Spawner

enum TYPE { TIME, TRIGGER }

func _enter_tree() -> void:
	_init_trigger_area_on_entering_tree()

func _ready() -> void:
	_init_timer()
	_init_trigger_area_on_ready()

#---------------------------------------TIME---------------------------------------
var spawn_cooldown: float = 2

func _init_timer():
	if has_node("Timer"):
		var timer: Timer = $Timer
		timer.timeout.connect(_on_timeout)
		timer.wait_time = spawn_cooldown
		timer.one_shot = false
		timer.autostart = true
	pass

func _on_timeout():
	execute()

#---------------------------------------TRIGGER---------------------------------------
var trigger_size: Vector2:
	set(value):
		trigger_size = value
		update_size(value)

var trigger_position: Vector2:
	set(value):
		trigger_position = value
		update_pos(value)
		#call_deferred("update_pos", trigger_position)

var _trigger_area: Area2D = null
var _trigger_collision: CollisionShape2D = null

func _init_trigger_area_on_entering_tree():
	if has_node("Area2D"):
		_trigger_area = $Area2D
		_trigger_collision = $Area2D/CollisionShape2D
		_update_properties()

func _init_trigger_area_on_ready():
	if _trigger_area:
		_update_properties()
		_trigger_area.body_entered.connect(_on_body_entered)

func _update_properties():
	update_size(trigger_size)
	update_pos(trigger_position)

func update_size(size: Vector2):
	if _trigger_collision:
		_trigger_collision.shape.size = size
	pass

func update_pos(pos: Vector2):
	if _trigger_area:
		_trigger_area.position = pos
	pass

func _on_body_entered(_body: Node2D):
	execute()
	call_deferred("deactivate_spawner")
	pass

func deactivate_spawner():
	_trigger_collision.disabled = true

#---------------------------------INSPECTOR SETTING---------------------------------
@export var type: TYPE = TYPE.TIME:
	set = set_type

func set_type(value: TYPE):
	if type != value:
		type = value
		# Crucial: Forces the Inspector to update its list of properties
		notify_property_list_changed()

func _get_property_list() -> Array:
	var properties = []

	match type:
		TYPE.TIME:
			# Show TIME properties
			properties.append({
				"name": "spawn_cooldown",
				"type": TYPE_FLOAT,
				"usage": PROPERTY_USAGE_DEFAULT
			})
		TYPE.TRIGGER:
			# Show TRIGGER properties
			properties.append({
				"name": "trigger_size",
				"type": TYPE_VECTOR2,
				"usage": PROPERTY_USAGE_DEFAULT
			})
			properties.append({
				"name": "trigger_position",
				"type": TYPE_VECTOR2,
				"usage": PROPERTY_USAGE_DEFAULT
			})

	return properties
