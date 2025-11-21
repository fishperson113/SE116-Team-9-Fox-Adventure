extends Area2D
class_name HurtArea2D

# signal when hurt
signal hurt(attacker: BaseCharacter, direction: Vector2, damage: float)

# called when take damage
func take_damage(attacker: BaseCharacter, direction: Vector2, damage: float):
	hurt.emit(attacker, direction, damage)
