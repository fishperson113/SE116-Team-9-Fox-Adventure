class_name PatrolController

var _movement_range: float = 0
var _start_position: Vector2 = Vector2.ZERO

func _init(movement_range: float) -> void:
	_movement_range = movement_range

func track_patrol(current_position: Vector2) -> bool:
	return _start_position.distance_to(current_position) >= _movement_range

func set_start_position(position: Vector2) -> void:
	_start_position = position

func set_movement_range(movement_range) -> void:
	_movement_range = movement_range
