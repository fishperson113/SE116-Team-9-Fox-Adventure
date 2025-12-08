class_name DropData
extends Node2D

@export var min_drop: int = 0
@export var max_drop: int = 0
@export var drop_table: Array[Dropable] = []

var _cumulative_weights: Array[int] = []
var _total_weight: int = 0

func _ready() -> void:
	_build_weight_table()

func _build_weight_table() -> void:
	_cumulative_weights.clear()
	_total_weight = 0

	for d in drop_table:
		_total_weight += d.weight
		_cumulative_weights.append(_total_weight)

# Main interface
# Returns an array of instantiated drop items based on the drop table rules.
func roll() -> Array[Node]:
	if drop_table.is_empty():
		return []

	var count := randi_range(min_drop, max_drop)
	var results: Array[Node] = []

	for i in count:
		var dropable := _pick_random()
		if dropable:
			var inst = dropable.item.instantiate()
			results.append(inst)

	return results

func _pick_random() -> Dropable:
	if _total_weight <= 0:
		return null

	var r := randi_range(0, _total_weight - 1)
	return _binary_search(r)

func _binary_search(weight: int) -> Dropable:
	var left := 0
	var right := _cumulative_weights.size() - 1

	while left < right:
		var mid: int = (left + right) / 2

		if weight < _cumulative_weights[mid]:
			right = mid
		else:
			left = mid + 1

	return drop_table[left]
