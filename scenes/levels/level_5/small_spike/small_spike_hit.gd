class_name SmallSpikeHitArea2D
extends HitArea2D

signal hitting(body: BaseCharacter)

var target_name: String = ""
var condition: Callable

func hit(hurt_area):
	var target = hurt_area.find_parent(target_name) as BaseCharacter
	if not target:
		return
	if condition and not condition.call(target):
		return
		
	hitting.emit(target)
	super.hit(hurt_area)

func set_target_name(name: String):
	target_name = name

func set_condition(callback: Callable):
	condition = callback
