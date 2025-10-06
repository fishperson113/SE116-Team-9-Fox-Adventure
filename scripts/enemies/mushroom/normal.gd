extends EnemyState

func _enter() -> void:
	obj.get_animation_controller().change_animation("normal")

func _exit() -> void:
	pass

func _update( _delta ):
	if obj.is_hit():
		fsm.change_state(fsm.states.hit)
	pass
