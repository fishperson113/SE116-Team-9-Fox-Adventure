extends Area2D
class_name DeathPit

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("YES")
		body.set_empty_health()
