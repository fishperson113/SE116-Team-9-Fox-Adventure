extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.prepare_time
	pass

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		change_state(fsm.states.attack)
	pass
