extends ChestState

func _enter() -> void:
	obj.is_unlockable = false
	obj.change_animation("open")
	LootSystem.spawn_loot(obj, obj.get_loot_effect())
