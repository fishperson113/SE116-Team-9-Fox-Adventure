extends Node
class_name Inventory

signal inventory_changed 

var item_archive: Array[Dictionary]
@export var item_storer: ItemStorer

func _ready() -> void:
	item_archive = GameManager.inventory_data
	#SaveSystem.delete_inventory_file()
	pass

func show_item_archive() -> void:
	if len(item_archive) == 0:
		print("No item in inventory")
		return
	
	for i in range(len(item_archive)):
		print(i, ": ", item_archive[i])
	print("\n")
	pass

func insert_item(item_type: String, item_detail) -> void:
	for i in range(len(item_archive)):
		if item_archive[i]["item_type"] != item_type:
			continue
		
		if not GameManager.check_object_type(item_archive[i]["item_detail"][0], item_detail):
			continue
		
		# --- Update existing stack ---
		item_archive[i]["item_detail"].append(item_detail)
		print("Added existing item")
		show_item_archive()

		emit_signal("inventory_changed")
		return
	
	# --- Create new stack ---
	var item = {
		"item_type": item_type,
		"item_detail": [item_detail]
	}
	item_archive.append(item)

	print("Added new item")
	show_item_archive()

	emit_signal("inventory_changed")
	pass

func find_exact_item(item_type: String, item_detail) -> Variant:
	var final_item_index: int = -1
	for item_index in len(item_archive):
		if item_archive[item_index]["item_type"] == item_type:
			final_item_index = item_index
			break
	
	if final_item_index == -1:
		return null

	if not GameManager.check_object_type(item_archive[final_item_index]["item_detail"][0], item_detail):
		return null
		
	return item_archive[final_item_index]["item_detail"][0]

func add_to_store_item(item_type: String, item_detail) -> void:
	if find_exact_item(item_type, item_detail) == null:
		print("Item is not available in inventory")
		return
	
	item_storer.add_item(item_type, item_detail)
	remove_item(item_type, item_detail)

	print("Successfully added item to slot")
	emit_signal("inventory_changed")
	pass

func remove_item(item_type: String, item_detail) -> void:
	var final_item_index: int = -1
	for item_index in len(item_archive):
		if item_archive[item_index]["item_type"] == item_type:
			final_item_index = item_index
			break
	
	if final_item_index == -1:
		return
	
	if GameManager.check_object_type(item_detail, item_archive[final_item_index]["item_detail"][0]):
		item_archive[final_item_index]["item_detail"].remove_at(0)

		if len(item_archive[final_item_index]["item_detail"]) == 0:
			item_archive.remove_at(final_item_index)

		emit_signal("inventory_changed")
		return
	pass

func save_inventory() -> void:
	GameManager.inventory_data = item_archive.duplicate(true)
	GameManager.save_inventory_data()
