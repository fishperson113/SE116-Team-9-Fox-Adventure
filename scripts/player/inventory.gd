extends Node
class_name Inventory

var item_archive: Array[Dictionary]
@export var item_storer: ItemStorer

func _ready() -> void:
	item_archive = GameManager.inventory_data
	#DO NOT delete this, just for faster progression
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

func is_item_type_available(item_type: String) -> bool:
	if len(item_archive) == 0:
		print("No item in inventory")
		return false
	
	for i in len(item_archive):
		if item_archive[i]["item_type"] == item_type:
			return true
	return false

func insert_item(item_type: String, item_detail: Dictionary) -> void:
	for i in range(len(item_archive)):
		if item_archive[i]["item_type"] == item_type:
			item_archive[i]["item_detail"].append(item_detail)
			print("Added existing item")
			show_item_archive()
			return
	
	var item = {
		"item_type" = item_type,
		"item_detail" = []
	}
	item["item_detail"].append(item_detail)
	item_archive.append(item)
	print("Added new item")
	show_item_archive()
	pass

func find_exact_item(item_type: String, item_data: Dictionary) -> Dictionary:
	for item_index in len(item_archive):
		if item_archive[item_index]["item_type"] == item_type:
			for detail_index in len(item_archive[item_index]["item_detail"]):
				if same_dict(item_data, item_archive[item_index]["item_detail"][detail_index]):
					return item_archive[item_index]["item_detail"][detail_index]
			return {}
	return {}

func add_to_store_item(item_type: String, item_detail: Dictionary) -> void:
	if item_type == "item_key":
		print("Keys can't be added to slots")
		return
	
	if find_exact_item(item_type, item_detail) == {}:
		print("Item is not available in inventory")
		return
	
	item_storer.add_item(item_type, item_detail)
	remove_item(item_type, item_detail)
	print("Successfully added item to slot")
	pass

func remove_item(item_type: String, item_detail: Dictionary) -> void:
	for item_index in len(item_archive):
		if item_archive[item_index]["item_type"] == item_type:
			for detail_index in len(item_archive[item_index]["item_detail"]):
				if same_dict(item_detail, item_archive[item_index]["item_detail"][detail_index]):
					item_archive[item_index]["item_detail"].remove_at(detail_index)
					if len(item_archive[item_index]["item_detail"]) == 0:
						item_archive.remove_at(item_index);
					return
			return
	pass
	
func is_key_available() -> bool:
	for i in range(len(item_archive)):
		if item_archive[i]["item_type"] == "item_key":
			return true
	return false

func same_dict(a: Dictionary, b: Dictionary) -> bool:
	if a.size() != b.size():
		return false
	for key in a.keys():
		if not b.has(key):
			return false
		if a[key] != b[key]:
			return false
	return true

func save_inventory() -> void:
	GameManager.inventory_data = item_archive
	GameManager.save_inventory_data()
