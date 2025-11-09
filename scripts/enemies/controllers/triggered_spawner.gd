@tool
extends Spawner

@export var size: Vector2:
	set(value):
		size = value
		update_size(value)

@export var pos: Vector2:
	set(value):
		pos = value
		update_pos(value)

@onready var trigger_area := $Area2D
@onready var trigger_collision := $Area2D/CollisionShape2D

func _ready() -> void:
	super._ready()
	update_size(size)
	update_pos(pos)
	trigger_area.body_entered.connect(_on_body_entered)

func update_size(size: Vector2):
	if trigger_collision:
		trigger_collision.shape.size = size
	pass

func update_pos(pos: Vector2):
	if trigger_area:
		trigger_area.position = pos
	pass

func _on_body_entered(body: Node2D):
	bias_spawn()
	call_deferred("deactivate_spawner")
	pass

func deactivate_spawner():
	trigger_collision.disabled = true
