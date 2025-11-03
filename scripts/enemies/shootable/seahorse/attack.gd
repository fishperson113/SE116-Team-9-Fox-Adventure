class_name EnemyShootState
extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.shoot_time
	pass
	
func _exit() -> void:
	super._exit()
	pass

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.normal)
