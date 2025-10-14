class_name EnemyState
extends FSMState

func try_attack() -> void:
	if obj.can_attack():
		fsm.change_state(fsm.states.attack)

func try_recover() -> void:
	if obj.is_alive():
		fsm.change_state(fsm.states.idle)
	else:
		fsm.change_state(fsm.states.dead)

func take_damage(_damage_dir, damage: int) -> void:
	obj.velocity.x = _damage_dir.x * 150
	obj.take_damage(damage)
	change_state(fsm.states.hurt)
