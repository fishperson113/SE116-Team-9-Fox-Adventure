extends EnemyState

func _update( _delta ):
	super._update(_delta)
	try_attack()
