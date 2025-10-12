extends EnemyState

func _enter() -> void:
	obj.start_emerging_mode()
	timer = obj.emerging_time

func _exit() -> void:
	obj.end_emerging_mode()

func _update( _delta ):
	obj.update_emerging_mode(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.normal)
