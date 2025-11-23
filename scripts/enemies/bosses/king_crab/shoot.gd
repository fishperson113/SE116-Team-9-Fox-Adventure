extends EnemyState

func _update( _delta ):
	super._update(_delta)
	if obj.is_attaching():
		fsm.change_state(fsm.states.recall)
	pass

func take_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	pass
