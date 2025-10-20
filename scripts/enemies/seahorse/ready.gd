extends EnemyState

func _enter() -> void:
	#obj.start_ready_mode()
	pass

func _exit() -> void:
	#obj.end_ready_mode()
	pass

func _update( _delta ):
	#obj.update_ready_mode(_delta)
	if obj.can_attack():
		fsm.change_state(fsm.states.attack)
