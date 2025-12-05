extends Node
class_name InventoryCheck

@onready var player: Player = $"../Player"

var weapon_1_1: Resource = load("res://data/tests/weapon_1764827145.062.tres")
var weapon_1_2: Resource = load("res://data/tests/weapon_1764827599.591.tres")
var weapon_2_1: Resource = load("res://data/tests/weapon_1764827592.117.tres")

func _on_show_inventory_pressed() -> void:
	player.inventory.show_item_archive()
	pass # Replace with function body.

func _on_return_item_pressed() -> void:
	player.item_storer.return_item("item_fun", {})
	#player.item_storer.return_item()
	pass # Replace with function body.

func _on_show_slots_button_pressed() -> void:
	player.item_storer.show_slots()
	pass # Replace with function body.

func _on_add_weapon_11_pressed() -> void:
	player.inventory.insert_item("weapon_blade", weapon_1_1)
	pass # Replace with function body.

func _on_add_weapon_12_pressed() -> void:
	player.inventory.insert_item("weapon_blade", weapon_1_2)
	pass # Replace with function body.

func _on_add_weapon_21_pressed() -> void:
	player.inventory.insert_item("weapon_blade", weapon_2_1)
	pass # Replace with function body.

func _on_add_slot_weapon_11_pressed() -> void:
	player.inventory.add_to_store_item("weapon_blade", weapon_1_1)
	pass # Replace with function body.

func _on_add_slot_weapon_12_pressed() -> void:
	player.inventory.add_to_store_item("weapon_blade", weapon_1_2)
	pass # Replace with function body.

func _on_add_slot_weapon_21_pressed() -> void:
	player.inventory.add_to_store_item("weapon_blade", weapon_2_1)
	pass # Replace with function body.

func _on_save_inventory_and_slots_pressed() -> void:
	player.inventory.save_inventory()
	player.item_storer.save_slots()
	pass # Replace with function body.
