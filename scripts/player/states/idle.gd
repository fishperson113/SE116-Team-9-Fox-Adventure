extends PlayerState

## Idle state for player character

func _enter() -> void:
	obj.change_animation("idle")

func _update(_delta: float) -> void:
	#Control jump
	control_dash()
	control_jump()
	control_moving()
	control_attack()
	control_throwing(_delta)
	control_unequip()
	#If not on floor change to fall
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
