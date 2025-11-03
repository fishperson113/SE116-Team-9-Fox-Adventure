extends Node

func _ready() -> void:
	GameManager.load_inventory_data()
	GameManager.load_slots_data()
