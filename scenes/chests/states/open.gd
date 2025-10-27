extends ChestState

func _enter() -> void:
	obj.is_unlockable = false
	obj.unlock_chest.emit()
	obj.change_animation("open")
