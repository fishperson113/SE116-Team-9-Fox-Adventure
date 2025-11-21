extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.launch_time

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.stun)

func take_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	pass
