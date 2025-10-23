extends EnemyState

func _enter() -> void:
	obj.start_defend_mode()

func _exit() -> void:
	obj.end_defend_mode()

func _update( _delta ):
	obj.update_defend_mode(_delta)
	if not obj.can_defend():
		fsm.change_state(fsm.states.normal)
