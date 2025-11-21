extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.hide_time

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		fsm.change_state(fsm.states.emerging)

# When hiding, the body can't take damage
func take_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	obj.reflect_damage(_attacker, _direction, _damage)
	pass
