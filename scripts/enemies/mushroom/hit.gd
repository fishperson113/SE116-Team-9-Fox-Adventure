extends EnemyState

func _enter() -> void:
	obj._animation_controller.change_animation("hit")
	pass

func _exit() -> void:
	pass

func _update( _delta ):
	pass

func _on_animated_sprite_2d_animation_finished() -> void:
	fsm.change_state(fsm.states.normal)
