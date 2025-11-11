extends Node
class_name InventoryCheck

@onready var player: Player = $"../Player"

func _on_show_inventory_pressed() -> void:
	player.inventory.show_item_archive()
	pass # Replace with function body.

func _on_add_weapon_0_pressed() -> void:
	player.inventory.insert_item("weapon_blade", 
	{
		"damage": 20,
		"erosion_rate": 80
	})
	#player.inventory.insert_item(true, "weapon_sample")
	pass # Replace with function body.

func _on_add_weapon_1_pressed() -> void:
	player.inventory.insert_item("weapon_blade", 
	{
		"damage": 40,
		"erosion_rate": 60
	})
	#player.inventory.insert_item(true, "weapon_blade")
	pass # Replace with function body.

func _on_add_item_0_pressed() -> void:
	player.inventory.insert_item("item_whatever",
	{
		"tension": 10
	})
	#player.inventory.insert_item(false, "item_0")
	pass # Replace with function body.

func _on_add_item_1_pressed() -> void:
	player.inventory.insert_item("item_fun", {})
	#player.inventory.insert_item(false, "chest_key")
	pass # Replace with function body.

func _on_add_to_slot_pressed() -> void:
	player.inventory.add_to_store_item("weapon_blade", 
	{
		"damage": 20,
		"erosion_rate": 80
	})
	#player.inventory.add_to_store_item()
	pass # Replace with function body.

func _on_return_item_pressed() -> void:
	player.item_storer.return_item("item_fun", {})
	#player.item_storer.return_item()
	pass # Replace with function body.

func _on_show_slots_button_pressed() -> void:
	player.item_storer.show_slots()
	pass # Replace with function body.
