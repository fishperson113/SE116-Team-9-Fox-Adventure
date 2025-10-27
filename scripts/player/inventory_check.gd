extends Node
class_name InventoryCheck

@onready var player: Player = $"../Player"

func _on_show_inventory_pressed() -> void:
	player.inventory.show_item_archive()
	pass # Replace with function body.

func _on_next_item_in_inventory_pressed() -> void:
	player.inventory.select_next_item()
	pass # Replace with function body.

func _on_previous_item_in_inventory_pressed() -> void:
	player.inventory.select_previous_item()
	pass # Replace with function body.

func _on_add_weapon_0_pressed() -> void:
	player.inventory.insert_item(true, 0)
	pass # Replace with function body.

func _on_add_weapon_1_pressed() -> void:
	player.inventory.insert_item(true, 1)
	pass # Replace with function body.

func _on_add_item_0_pressed() -> void:
	player.inventory.insert_item(false, 0)
	pass # Replace with function body.

func _on_add_item_1_pressed() -> void:
	player.inventory.insert_item(false, 1)
	pass # Replace with function body.

func _on_add_to_slot_pressed() -> void:
	player.inventory.add_to_store_item()
	pass # Replace with function body.

func _on_return_item_pressed() -> void:
	player.item_storer.return_item()
	pass # Replace with function body.
