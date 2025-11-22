extends PlayerState

func _enter() -> void:
	obj.velocity.x = 350
	obj.velocity.y = -250
	obj.change_animation("jump")
	
func _update(_delta: float):
	if not obj.is_on_floor():
		obj.velocity.y += obj.gravity * _delta
	
	if obj.is_on_floor() and obj.velocity.y >= 0:
		change_state(fsm.states.fall)
		

func _exit() -> void:
	pass
