extends EnemyState

func _enter() -> void:
	obj.start_recall_mode()
	timer = obj.recall_time

func _exit() -> void:
	obj.end_recall_mode()
	pass

func _update( _delta ):
	obj.update_recall_mode(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.stun)
	pass

func take_damage() -> void:
	pass
