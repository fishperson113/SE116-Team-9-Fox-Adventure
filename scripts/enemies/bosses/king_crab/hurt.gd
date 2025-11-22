extends EnemyHurtState

func take_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	pass

func try_recover() -> void:
	if obj.is_alive():
		fsm.change_state(fsm.previous_state)
	else:
		fsm.change_state(fsm.states.dead)
