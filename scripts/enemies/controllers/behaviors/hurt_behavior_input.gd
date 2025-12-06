class_name HurtBehaviorInput
extends BehaviorInput

var attacker: BaseCharacter = null
var direction: Vector2 = Vector2.ZERO
var damage_taken: float = 0.0

func _init(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	attacker = _attacker
	direction = _direction
	damage_taken = _damage
