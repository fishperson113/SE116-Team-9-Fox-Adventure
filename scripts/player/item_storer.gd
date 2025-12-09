extends Node
class_name ItemStorer
signal slot_changed(new_slot_index)

var number_of_slots: int
var items_archive: Array[Dictionary]

var item_slot: int = 0

@onready var weapon_thrower: WeaponThrower = $"../WeaponThrower"
@export var inventory: Inventory

func _init() -> void:
	number_of_slots = GameManager.slots_size
	items_archive.resize(number_of_slots)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_slot_left"):
		switch_item_slot(-1)
	elif Input.is_action_just_pressed("change_slot_right"):
		switch_item_slot(1)


# ---------------------------------------------------------
# ADD ITEM → item_detail = path String
# ---------------------------------------------------------
func add_item(item_type: String, item_path: String) -> bool:
	for i in range(number_of_slots):

		# Slot trống → nhét vào
		if not items_archive[i].has("item_type"):
			items_archive[i] = {
				"item_type": item_type,
				"item_detail": [item_path]
			}
			print("Successfully added an object from inventory")
			return true

		# Slot chứa cùng item_type & không phải weapon → stack
		elif not is_slot_weapon(i) and items_archive[i]["item_type"] == item_type:
			items_archive[i]["item_detail"].append(item_path)
			print("Successfully added an object from inventory")
			return true

	# Nếu không có slot phù hợp → trả về inventory
	inventory.insert_item(item_type, item_path)
	return true

func switch_item_slot(offset: int) -> void:
	if item_slot + offset < 0:
		item_slot = 0
	elif item_slot + offset >= number_of_slots:
		item_slot = number_of_slots - 1
	else:
		item_slot += offset

	_equip_current_slot_weapon()

	emit_signal("slot_changed", item_slot)
	print("Switched to slot ", item_slot, "\n", items_archive[item_slot])


# ---------------------------------------------------------
# EQUIP WEAPON → load resource từ path string
# ---------------------------------------------------------
func _equip_current_slot_weapon():

	GameManager.player.unequip_weapon()
	if not is_slot_available():
		return

	var item = items_archive[item_slot]

	if not item.has("item_detail"):
		return

	if item["item_detail"].is_empty():
		return

	if not item["item_type"].begins_with("weapon_"):
		return

	# -----------------------------
	# LOAD RESOURCE TỪ PATH
	# -----------------------------
	var path: String = item["item_detail"][0]
	var weapon: WeaponData = load(path)

	if weapon == null:
		push_error("Failed to load weapon at path: " + path)
		return

	GameManager.player.equip_weapon(weapon)


func is_slot_available(slot_index: int = item_slot) -> bool:
	return items_archive[slot_index] != {}


func is_item_storer_full() -> bool:
	for i in range(number_of_slots):
		if not is_slot_available(i):
			return false
	return true


func is_slot_weapon(item_index: int = item_slot) -> bool:
	if items_archive[item_index].has("item_type"):
		return items_archive[item_index]["item_type"].begins_with("weapon_")
	return false


func get_item_type() -> String:
	return items_archive[item_slot]["item_type"]


# ---------------------------------------------------------
# REMOVE ITEM → compare path string
# ---------------------------------------------------------
func remove_item(item_type: String, item_path: String) -> void:
	if items_archive[item_slot]["item_type"] != item_type:
		print("Can't remove a different type of item")
		return

	if items_archive[item_slot]["item_detail"][0] == item_path:
		items_archive[item_slot]["item_detail"].remove_at(0)

		if items_archive[item_slot]["item_detail"].is_empty():
			items_archive[item_slot] = {}

		return


func return_item(item_type: String, item_path: String) -> void:
	if items_archive[item_slot] == {}:
		print("Slot is empty. Can't return item to inventory")
		return
	
	if items_archive[item_slot]["item_type"] != item_type:
		print("Can't return a different type of object to the inventory")
		return

	if items_archive[item_slot]["item_detail"][0] == item_path:
		inventory.insert_item(
			items_archive[item_slot]["item_type"],
			items_archive[item_slot]["item_detail"][0]
		)

		remove_item(
			items_archive[item_slot]["item_type"],
			items_archive[item_slot]["item_detail"][0]
		)

		return


func show_slots() -> void:
	print("List of slots:")
	for item_index in len(items_archive):
		if is_slot_weapon(item_index):
			print(item_index, ": ", items_archive[item_index])
		elif items_archive[item_index].is_empty():
			print(item_index, ": ", items_archive[item_index])
		else:
			print(item_index, ": ",
			items_archive[item_index]["item_type"],
			": size: ", items_archive[item_index]["item_detail"].size())
	print("\n")


func save_slots() -> void:
	GameManager.slots_data = items_archive.duplicate(true)
	GameManager.save_slots_data()
	switch_item_slot(item_slot)


func initialize_slots():
	items_archive = GameManager.slots_data.duplicate(true)

	if items_archive.is_empty():
		items_archive.resize(number_of_slots)
		for i in range(number_of_slots):
			items_archive[i] = {}

	_equip_current_slot_weapon()
	emit_signal("slot_changed", item_slot)

	print("ItemStorer initialized:", items_archive)
