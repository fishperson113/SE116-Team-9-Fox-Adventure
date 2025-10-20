extends EnemyState

var _cooldown: float = 0

func _enter() -> void:
	obj.change_animation("attack")
	obj.stop_move()
	timer = obj.get_shoot_time()
	_cooldown = obj.get_shoot_interval()
	pass

func _exit() -> void:
	pass

func _update( _delta ):
	_cooldown -= _delta
	if _cooldown <= 0:
		_cooldown = obj.get_shoot_interval()
		obj.fire()
	if update_timer(_delta):
		change_state(fsm.previous_state)	
	pass
