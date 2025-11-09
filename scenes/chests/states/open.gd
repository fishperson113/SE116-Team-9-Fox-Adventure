extends ChestState

func _enter() -> void:
	obj.is_unlockable = false
	obj.change_animation("open")
