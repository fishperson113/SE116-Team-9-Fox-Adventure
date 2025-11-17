class_name Droplet
extends RigidBody2D

signal hit(body: Node2D)

func _on_area_2d_body_entered(body: Node2D) -> void:
	hit.emit(body)
	queue_free()
