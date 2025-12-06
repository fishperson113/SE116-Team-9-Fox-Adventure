extends Node
class_name ItemStorer

var number_of_slots: int
var items_archive: Array[Dictionary]

var item_slot: int = 0

@onready var weapon_thrower: WeaponThrower = $"../WeaponThrower"
@export var inventory: Inventory

func _init() -> void:
	number_of_slots = GameManager.slots_size
	items_archive.resize(number_of_slots)

func _ready() -> void:
	for i in range(number_of_slots):
		items_archive[i] = {}
	items_archive = GameManager.slots_data
	change_item()
	
	#DO NOT delete this, just for faster progression
	#SaveSystem.delete_slots_file()
	
	#This might be useful for demos, DO NOT delete this either
	#for i in range(200):
	#	add_item("weapon_blade", {})
	#change_item()
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_item"):
		switch_item_slot()

func add_item(item_type: String, item_detail) -> bool:
	if not items_archive[item_slot].has("item_type"):
		items_archive[item_slot] = {
			"item_type" = item_type,
			"item_detail" = []
		}
		items_archive[item_slot]["item_detail"].append(item_detail)
		print("Successfully added an object from inventory")
		change_item()
		return true
	
	if items_archive[item_slot]["item_type"] != item_type:
		print("Can't add a different type of existing object to the same slot")
		return false
	
	items_archive[item_slot]["item_detail"].append(item_detail)
	print("Successfully added an object from inventory")
	return true

func change_item(index_in_slot: int = 0) -> void:
	if is_slot_weapon() and is_slot_available():
		weapon_thrower.change_weapon(items_archive[item_slot]["item_type"], items_archive[item_slot]["item_detail"][index_in_slot])
	else:
		weapon_thrower.change_weapon("none", {})

func switch_item_slot() -> void:
	if item_slot + 1 >= number_of_slots:
		item_slot = 0
	else:
		item_slot += 1
	change_item()
	_equip_current_slot_weapon()
	print("Switched to slot ", item_slot, "\n", items_archive[item_slot])


func _equip_current_slot_weapon():
	if not is_slot_available():
		GameManager.player.unequip_weapon()
		return

	var item = items_archive[item_slot]

	if not item.has("item_detail"):
		GameManager.player.unequip_weapon()
		return

	if item["item_detail"].is_empty():
		GameManager.player.unequip_weapon()
		return

	var weapon: WeaponData = item["item_detail"][0]
	GameManager.player.equip_weapon(weapon)
	

func is_slot_available() -> bool:
	if items_archive[item_slot] == {}:
		return false
	return true

func is_slot_weapon() -> bool:
	if items_archive[item_slot].has("item_type"):
		if items_archive[item_slot]["item_type"].begins_with("weapon_"):
			return true
	return false

func get_item_type() -> String:
	return items_archive[item_slot]["item_type"]

func remove_item(item_type: String, item_detail) -> void:
	if items_archive[item_slot]["item_type"] != item_type:
		print("Can't remove a different type of item")
		return
	
	if GameManager.check_object_type(items_archive[item_slot]["item_detail"][0], item_detail):
		items_archive[item_slot]["item_detail"].remove_at(0)
		if len(items_archive[item_slot]["item_detail"]) == 0:
			items_archive[item_slot] = {}
		change_item()
		return

func return_item(item_type: String, item_detail) -> void:
	if items_archive[item_slot] == {}:
		print("Slot is empty. Can't return item to inventory")
		return
	
	if items_archive[item_slot]["item_type"] != item_type:
		print("Can't return a different type of object to the inventory")
		return
	
	if GameManager.check_object_type(items_archive[item_slot]["item_detail"][0], item_detail):
		inventory.insert_item(
			items_archive[item_slot]["item_type"],
			items_archive[item_slot]["item_detail"][0]
			)
		remove_item(items_archive[item_slot]["item_type"], items_archive[item_slot]["item_detail"][0])
		change_item()
		return
	pass

func show_slots() -> void:
	print("List of slots:")
	for item_index in len(items_archive):
		print(item_index, ": ", items_archive[item_index])
	print("\n")

func save_slots() -> void:
	GameManager.slots_data = items_archive.duplicate(true)
	GameManager.save_slots_data()
