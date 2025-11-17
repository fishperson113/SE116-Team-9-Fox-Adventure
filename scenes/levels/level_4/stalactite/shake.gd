extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.shake_time
	pass

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.fall)
	pass
