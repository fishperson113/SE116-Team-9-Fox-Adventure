extends EnemyState

func _enter() -> void:
	obj.start_stop_roll_mode()
	timer = obj.stop_rolling_time

func _exit() -> void:
	obj.end_stop_roll_mode()

func _update( _delta ):
	obj.update_stop_roll_mode(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.normal)
