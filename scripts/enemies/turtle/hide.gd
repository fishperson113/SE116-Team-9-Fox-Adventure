extends EnemyState

func _enter() -> void:
	obj.start_hide_mode()
	timer = obj.hide_time

func _exit() -> void:
	obj.end_hide_mode()

func _update( _delta ):
	obj.update_hide_mode(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.emerging)
