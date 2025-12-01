extends EnemyState

func take_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	obj.take_damage(_damage)
	try_recover()
