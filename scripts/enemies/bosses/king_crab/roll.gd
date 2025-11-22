extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.rolling_time

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta) or obj.is_can_fall() or obj.is_touch_wall():
		fsm.change_state(fsm.states.stoproll)

func take_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	pass
