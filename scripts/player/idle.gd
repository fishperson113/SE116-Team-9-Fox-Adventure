extends PlayerState

## Idle state for player character

func _enter() -> void:
	obj.change_animation("idle")
	obj.jumpCount = 0

func _update(_delta: float) -> void:
	#Control jump
	control_jump()
	control_hit()
	control_moving()
	control_attack()
	control_defeat()
	#If not on floor change to fall
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
