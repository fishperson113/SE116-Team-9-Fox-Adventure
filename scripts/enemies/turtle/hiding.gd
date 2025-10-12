extends EnemyState

func _enter() -> void:
	obj.start_hiding_mode()
	timer = obj.hiding_time

func _exit() -> void:
	obj.end_hiding_mode()

func _update( _delta ):
	obj.update_hiding_mode(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.hide)
