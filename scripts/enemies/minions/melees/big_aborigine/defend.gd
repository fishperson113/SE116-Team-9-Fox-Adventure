extends EnemyState

func _update( _delta ):
	super._update(_delta)
	if not obj.can_defend():
		fsm.change_state(fsm.states.normal)
