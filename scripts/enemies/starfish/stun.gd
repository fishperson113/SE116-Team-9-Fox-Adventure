extends EnemyState

func _enter() -> void:
	obj.start_stun_mode()	
	timer = obj.stun_time
	pass

func _exit() -> void:
	obj.end_stun_mode()
	pass

func _update( _delta ):
	obj.update_stun_mode(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.normal)
	on_hurt()
	pass
