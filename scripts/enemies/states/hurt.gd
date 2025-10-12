class_name EnemyHurtState
extends EnemyState

func _enter() -> void:
	obj.start_hurt_mode()
	timer = obj.hurt_time
	pass

func _exit() -> void:
	obj.end_hurt_mode()
	pass

func _update( _delta ):
	obj.update_hurt_mode(_delta)
	if update_timer(_delta):
		try_recover()
	pass
