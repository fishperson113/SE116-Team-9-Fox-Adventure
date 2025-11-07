extends EnemyState

func _enter() -> void:
	obj.start_throw_mode()
	timer = obj.get_shoot_time()
	pass
	
func _exit() -> void:
	obj.end_throw_mode()
	pass

func _update( _delta ):
	obj.update_throw_mode()
	if update_timer(_delta):
		fsm.change_state(fsm.states.normal)
