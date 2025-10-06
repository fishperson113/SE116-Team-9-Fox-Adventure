class_name PatrolController
extends Node2D

var _movement_range: float = 0
var _patrol_distance: float = 0

func _init(movement_range: float) -> void:
	_movement_range = movement_range

func track_patrol(delta: float, movement_speed: float) -> bool:
	_patrol_distance += movement_speed * delta
	
	if _patrol_distance < _movement_range:
		return false
	
	_patrol_distance = 0
	return true
