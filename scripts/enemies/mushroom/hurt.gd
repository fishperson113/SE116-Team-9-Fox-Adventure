extends EnemyState

func _enter() -> void:
	obj.stop_moving()	
	obj.get_animation_controller().change_animation("hurt")
	obj.get_animation_controller().animation_finished.connect(_on_animation_finished)
	pass

func _exit() -> void:
	obj.get_animation_controller().animation_finished.disconnect()
	pass

func _update( _delta ):
	pass

func _on_animation_finished() -> void:
	fsm.change_state(fsm.previous_state)
