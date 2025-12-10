extends Node
class_name Inventory

signal inventory_changed 

var item_archive: Array[Dictionary]
@export var item_storer: ItemStorer

func _ready() -> void:
	item_archive = GameManager.inventory_data
	pass

func show_item_archive() -> void:
	if len(item_archive) == 0:
		print("No item in inventory")
		return
	
	for i in range(len(item_archive)):
		if is_item_weapon(i):
			print(i, ": ", item_archive[i])
		elif item_archive[i].is_empty():
			print(i, ": ", item_archive[i])
		else:
			print(i, ": ",
			item_archive[i]["item_type"],
			": size: ", item_archive[i]["item_detail"].size())
	print("\n")
	pass


func is_item_weapon(item_index: int) -> bool:
	return item_archive[item_index]["item_type"].begins_with("weapon_")


# ---------------------------------------------------------
# INSERT ITEM (only change: item_detail is now String path)
# ---------------------------------------------------------
func insert_item(item_type: String, item_path: String) -> void:
	# Weapon = unique, always separate entry
	if item_type.begins_with("weapon_"):
		var item = {
			"item_type": item_type,
			"item_detail": [item_path]  # store as string path
		}
		item_archive.append(item)

		print("Added new weapon item")
		show_item_archive()
		emit_signal("inventory_changed")
		return
	
	# Non-weapon = stacking
	for i in range(len(item_archive)):
		if item_archive[i]["item_type"] == item_type:
			item_archive[i]["item_detail"].append(item_path)
			print("Added existing item")
			show_item_archive()
			emit_signal("inventory_changed")
			return
	
	# New non-weapon item
	var item = {
		"item_type": item_type,
		"item_detail": [item_path]
	}
	item_archive.append(item)

	print("Added new non-weapon item")
	show_item_archive()
	emit_signal("inventory_changed")
	pass


# ---------------------------------------------------------
# FIND EXACT ITEM (compare string path)
# ---------------------------------------------------------
func find_exact_item(item_type: String, item_path: String) -> Variant:
	var final_item_index := -1

	for item_index in len(item_archive):
		if item_archive[item_index]["item_type"] == item_type:
			final_item_index = item_index
			break
	
	if final_item_index == -1:
		return null

	# compare string path
	if item_archive[final_item_index]["item_detail"][0] != item_path:
		return null
		
	return item_archive[final_item_index]["item_detail"][0]


# ---------------------------------------------------------
# ADD TO STORE (unchanged, except using string path)
# ---------------------------------------------------------
func add_to_store_item(item_type: String, item_path: String) -> void:
	if find_exact_item(item_type, item_path) == null:
		print("Item is not available in inventory")
		return
	
	item_storer.add_item(item_type, item_path)
	remove_item(item_type, item_path)

	print("Successfully added item to slot")
	emit_signal("inventory_changed")
	pass


# ---------------------------------------------------------
# REMOVE ITEM (compare string path)
# ---------------------------------------------------------
func remove_item(item_type: String, item_path: String) -> void:
	var final_item_index := -1

	for item_index in len(item_archive):
		if item_archive[item_index]["item_type"] == item_type:
			final_item_index = item_index
			break
	
	if final_item_index == -1:
		return
	
	# only compare string now
	if item_archive[final_item_index]["item_detail"][0] == item_path:
		item_archive[final_item_index]["item_detail"].remove_at(0)

		if len(item_archive[final_item_index]["item_detail"]) == 0:
			item_archive.remove_at(final_item_index)

		emit_signal("inventory_changed")
		return
	pass


# ---------------------------------------------------------
# SAVE INVENTORY (unchanged)
# ---------------------------------------------------------
func save_inventory() -> void:
	GameManager.inventory_data = item_archive.duplicate(true)
	GameManager.save_inventory_data()
	
func move(from: int, to: int):
	if from == to:
		return
	var temp = item_archive[to]
	item_archive[to] = item_archive[from]
	item_archive[from] = temp

	emit_signal("inventory_changed")
	debug_inventory()
	
func debug_inventory():
	print("\n=== DEBUG INVENTORY ===")
	for i in range(item_archive.size()):
		print(i, ": ", item_archive[i])
	print("========================\n")
