extends EnemyState

func take_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	obj.take_damage(_damage)
	if not obj.is_alive():
		fsm.change_state(fsm.states.dead)
