extends EnemyState

func _enter() -> void:
	obj.start_shoot_mode()

func _exit() -> void:
	obj.end_shoot_mode()
	pass

func _update( _delta ):
	obj.update_shoot_mode(_delta)
	if obj.is_attaching():
		fsm.change_state(fsm.states.recall)
	pass

func take_damage() -> void:
	pass
