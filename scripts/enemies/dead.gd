extends EnemyState

func _enter() -> void:
	obj.start_dead_mode()

func _exit() -> void:
	obj.end_dead_mode()
	pass

func _update( _delta ):
	obj.update_dead_mode(_delta)
	pass
