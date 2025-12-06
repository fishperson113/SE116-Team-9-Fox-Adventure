class_name EnemyState
extends FSMState

signal enter
signal update(delta: float)
signal exit
signal react(input: BehaviorInput)

func _enter() -> void:
	enter.emit()
	pass

func _exit() -> void:
	exit.emit()
	pass

func _update( _delta ):
	update.emit(_delta)
	pass

func update_timer(delta: float) -> bool:
	timer -= delta
	if timer <= 0:
		return true
	return false

func _react(input: BehaviorInput) -> void:
	react.emit(input)
