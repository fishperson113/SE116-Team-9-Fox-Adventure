extends EnemyNormalState

func _enter() -> void:
	super._enter()
	timer = obj.attack_cooldown

func _exit() -> void:
	super._exit()

func _update( _delta ):
	super._update(_delta)
	if obj.can_leave():
		fsm.change_state(fsm.states.leave)
	elif update_timer(_delta):
		if obj.can_attack():
			fsm.change_state(fsm.states.attack)
