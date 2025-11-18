extends Area2D
class_name EnemyAreaChecker

@onready var original_door = $".."

func _on_area_exited(area: Area2D) -> void:
	var remaining_enemies = get_overlapping_areas().filter(func(a):
		var root = a.get_owner()
		return root is Enemy
	)
	if remaining_enemies.is_empty():
		original_door.queue_free()
		
