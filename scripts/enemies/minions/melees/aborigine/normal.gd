extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.shoot_cooldown

func _exit() -> void:
	super._exit()

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.throw)
	#if obj.can_stab():
		#fsm.change_state(fsm.states.stab)
