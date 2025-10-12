extends NormalState

func _update( _delta ):
	obj.update_normal_mode(_delta)
	try_attack()
	on_hurt()
	on_hit()
