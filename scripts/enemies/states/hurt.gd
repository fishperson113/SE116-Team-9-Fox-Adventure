class_name EnemyHurtState
extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.hurt_time
	pass

func _exit() -> void:
	super._exit()
	pass

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		try_recover()
	pass

func take_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	pass
