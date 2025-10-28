extends EnemyHurtState

func _enter() -> void:
	super._enter()
	pass

func _exit() -> void:
	super._exit()
	pass

func _update( _delta ):
	super._update(_delta)
	pass

func take_damage() -> void:
	pass

func try_recover() -> void:
	if obj.is_alive():
		fsm.change_state(fsm.previous_state)
	else:
		fsm.change_state(fsm.states.dead)
