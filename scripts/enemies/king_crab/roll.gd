extends EnemyState

func _enter() -> void:
	obj.start_roll_mode()
	timer = obj.rolling_time

func _exit() -> void:
	obj.end_roll_mode()

func _update( _delta ):
	obj.update_roll_mode(_delta)
	if update_timer(_delta) or obj.is_environment_detected():
		fsm.change_state(fsm.states.stoproll)

func take_damage() -> void:
	pass
