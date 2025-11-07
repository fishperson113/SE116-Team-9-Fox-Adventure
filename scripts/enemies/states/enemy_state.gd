class_name EnemyState
extends FSMState

signal enter
signal update(delta: float)
signal exit

func _enter() -> void:
	enter.emit()
	pass

func _exit() -> void:
	exit.emit()
	pass

func _update( _delta ):
	update.emit(_delta)
	pass

func update_timer(delta: float) -> bool:
	timer -= delta
	if timer <= 0:
		return true
	return false

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
