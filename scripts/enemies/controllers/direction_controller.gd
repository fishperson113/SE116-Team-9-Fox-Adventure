class_name DirectionController
extends Node2D

signal _on_changed_direction

enum Direction {
	LEFT = -1, RIGHT = 1
}

var _obj: Node = null
var _direction: int = Direction.RIGHT
var _next_direction: int = -_direction

func _init(obj: Node) -> void:
	_obj = obj
	
func _update(delta: float) -> void:
	_check_changed_direction()

func turn_around() -> void:
	change_direction(-_direction)

func change_direction(new_direction: int) -> void:
	_next_direction = new_direction
	
func get_direction() -> int:
	return _direction

func _check_changed_direction() -> void:
	if _next_direction != _direction:
		_direction = _next_direction
		_on_changed_direction.emit()
		_obj.scale.x = _direction
