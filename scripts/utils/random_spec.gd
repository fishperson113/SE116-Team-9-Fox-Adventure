class_name RandomSpec

var min_offset: float
var max_offset: float

func _init(_min_offset, _max_offset):
	self.min_offset = _min_offset
	self.max_offset = _max_offset

func get_random() -> float:
	return randf_range(min_offset, max_offset)
