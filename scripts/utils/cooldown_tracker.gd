class_name CooldownTracker
extends RefCounted

var cooldown: float = 0

func set_cooldown(_cooldown: float) -> void:
	cooldown = _cooldown

func track(delta: float) -> bool:
	cooldown -= delta
	if cooldown <= 0:
		return true
	return false
