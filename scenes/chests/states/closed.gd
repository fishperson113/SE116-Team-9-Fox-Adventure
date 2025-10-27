extends ChestState

func _enter() -> void:
	obj.change_animation("closed")

func _update(delta) -> void:
	if Input.is_action_just_pressed("unlock_chest") and obj.is_unlockable:
		change_state(fsm.states.open)
