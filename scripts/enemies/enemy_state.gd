class_name EnemyState
extends FSMState

func try_attack() -> void:
	if obj.can_attack():
		fsm.change_state(fsm.states.attack)

func try_recover() -> void:
	if obj.is_alive():
		fsm.change_state(fsm.states.normal)
	else:
		fsm.change_state(fsm.states.dead)

func take_damage() -> void:
	change_state(fsm.states.hurt)
