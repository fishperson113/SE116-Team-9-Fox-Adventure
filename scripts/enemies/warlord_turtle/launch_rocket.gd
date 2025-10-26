extends EnemyState

func _enter() -> void:
	obj.start_launch_rocket_mode()
	timer = obj.launch_time

func _exit() -> void:
	obj.end_launch_rocket_mode()

func _update( _delta ):
	obj.update_launch_rocket_mode(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.stun)
