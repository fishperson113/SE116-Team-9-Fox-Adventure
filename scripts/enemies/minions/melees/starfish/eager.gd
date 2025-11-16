extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.eager_time
	pass

func _update( _delta ):
	super._update(_delta)
	if obj.can_attack():
		timer = obj.eager_time
	elif update_timer(_delta):
		change_state(fsm.states.stun)
	pass
