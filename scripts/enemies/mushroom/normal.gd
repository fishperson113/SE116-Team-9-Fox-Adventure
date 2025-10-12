extends EnemyState

func _enter() -> void:
	obj.get_animation_controller().change_animation("normal")

func _exit() -> void:
	pass

func _update( _delta ):
	obj.try_patrol_turn(_delta)
	obj.on_hurt()
