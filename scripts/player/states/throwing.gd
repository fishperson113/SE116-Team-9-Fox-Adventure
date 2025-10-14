extends PlayerState

func _enter() -> void:
	obj.change_animation("idle")
	pass

func _update(_delta: float) -> void:
	if !control_throwing(_delta):
		if !obj.is_on_floor():
			change_state(fsm.states.fall)
		else:
			change_state(fsm.states.idle)
