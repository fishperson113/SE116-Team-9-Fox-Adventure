class_name EnemyNormalState
extends EnemyState

func _enter() -> void:
	obj.start_normal_mode()

func _exit() -> void:
	obj.end_normal_mode()

func _update( _delta ):
	obj.update_normal_mode(_delta)
