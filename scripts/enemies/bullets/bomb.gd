class_name Bomb
extends RigidBody2D

@onready var _hit_area: HitArea2D = $HitArea2D

func set_damage(damage: float) -> void:
	_hit_area.set_dealt_damage(damage)

func _on_hit_area_2d_body_entered(_body: Node2D) -> void:
	queue_free()
