extends EnemyNormalState

func _enter() -> void:
	super._enter()

func _exit() -> void:
	super._exit()

func _update( _delta ):
	super._update(_delta)
	if obj.can_defend():
		fsm.change_state(fsm.states.defend)
	
