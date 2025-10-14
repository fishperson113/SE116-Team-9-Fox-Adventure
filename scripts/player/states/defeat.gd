extends PlayerState

func _enter() -> void:
	#Change animation to fall
	obj.velocity.x = 0
	obj.change_animation("defeat")
	pass

func _update(_delta: float) -> void:
	pass
