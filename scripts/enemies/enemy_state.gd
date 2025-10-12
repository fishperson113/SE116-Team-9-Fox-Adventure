class_name EnemyState
extends Node

var fsm: EnemyFSM = null
var obj: Enemy = null
var timer: float = 0.0

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update( _delta ):
	pass

# Update timer and return true if timer is finished
func update_timer(delta: float) -> bool:
	if timer <= 0:
		return false
	timer -= delta
	if timer <= 0:
		return true
	return false

func on_hurt() -> void:
	if not fsm.changing_signals.has("hurt"):
		return
	fsm.change_state(fsm.states.hurt)

func on_hit() -> void:
	if fsm.changing_signals.has("hit"):
		fsm.change_state(fsm.states.stun)

func try_attack() -> void:
	if obj.can_attack():
		fsm.change_state(fsm.states.attack)

func try_recover() -> void:
	if obj.is_alive():
		fsm.change_state(fsm.states.idle)
	else:
		fsm.change_state(fsm.states.dead)
