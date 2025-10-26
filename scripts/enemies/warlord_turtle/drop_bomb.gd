extends EnemyState

func _enter() -> void:
	obj.start_drop_bomb_mode()
	timer = obj.drop_bomb_time

func _exit() -> void:
	obj.end_drop_bomb_mode()

func _update( _delta ):
	obj.update_drop_bomb_mode(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.normal)
