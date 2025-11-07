extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.shoot_cooldown

func _exit() -> void:
	super._exit()

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		if obj.can_attack():
			fsm.change_state(fsm.states.shoot)
