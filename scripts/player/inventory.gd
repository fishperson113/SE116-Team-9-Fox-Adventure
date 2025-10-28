extends Node
class_name Inventory

var item_archive: Array[Dictionary]
@export var item_storer: ItemStorer
var item_select: int = 0

func show_item_archive() -> void:
	if len(item_archive) == 0:
		print("No item in inventory")
		return
	
	for i in range(len(item_archive)):
		print(item_archive[i])
	print("\n")
	pass

func is_item_available(item_index: int) -> bool:
	if len(item_archive) == 0:
		print("No item in inventory")
		return false
	if item_index < 0:
		print("Minimum index selected")
		return false
	if item_index >= len(item_archive):
		print("Maximum index selected")
		return false
	
	item_select = item_index
	print("Selected ", item_archive[item_select])
	return true

func select_next_item() -> void:
	var item_index = item_select + 1
	is_item_available(item_index)
	pass

func select_previous_item() -> void:
	var item_index = item_select - 1
	is_item_available(item_index)
	pass

func insert_item(is_weapon: bool, item_type: String) -> void:
	for i in range(len(item_archive)):
		if item_archive[i]["is_weapon"] == is_weapon and item_archive[i]["item_type"] == item_type:
			item_archive[i]["number_of_item"] += 1
			print("Added existing item")
			show_item_archive()
			return
	
	var item = {
		"is_weapon" = is_weapon,
		"item_type" = item_type,
		"number_of_item" = 1
	}
	item_archive.append(item)
	print("Added new item")
	show_item_archive()
	pass

func add_to_store_item() -> void:
	if item_archive[item_select]["item_type"] == "chest_key":
		print("Keys can't be added to slots")
		return
	if !is_item_available(item_select):
		print("Item is not available in inventory")
		return
	var is_add_success = item_storer.add_item(
		item_archive[item_select]["is_weapon"],
		item_archive[item_select]["item_type"]
	)
	if !is_add_success:
		return
	
	remove_item(item_select)
	pass

func remove_item(item_index: int) -> void:
	item_archive[item_index]["number_of_item"] -= 1
	if item_archive[item_index]["number_of_item"] == 0:
		item_archive.remove_at(item_index)
		if item_index >= len(item_archive) and item_index != 0:
			item_index = len(item_archive) - 1

func is_key_available() -> bool:
	for i in range(len(item_archive)):
		if item_archive[i]["item_type"] == "chest_key":
			return true
	return false

func remove_key() -> void:
	for i in range(len(item_archive)):
		if item_archive[i]["item_type"] == "chest_key":
			remove_item(i)
			return
