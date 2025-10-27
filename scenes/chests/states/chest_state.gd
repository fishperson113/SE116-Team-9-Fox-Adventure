class_name ChestState
extends FSMState

func unlock_chest() -> void:
	change_state(fsm.states.open)
	pass
