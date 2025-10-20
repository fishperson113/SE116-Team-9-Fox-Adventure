class_name EnemyAttackState
extends EnemyState

func _enter() -> void:
	obj.start_attack_mode()
	pass
	
func _exit() -> void:
	obj.end_attack_mode()
	pass

func _update( _delta ):
	obj.update_attack_mode(_delta)
	pass
