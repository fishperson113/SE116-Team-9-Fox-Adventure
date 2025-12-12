extends Node
class_name ItemStorer
signal slot_changed(new_slot_index)
signal info_panel_change(weapon_data:WeaponData)
signal item_destroyed(slot_index)
var number_of_slots: int
var item_archive: Array[Dictionary]

var item_slot: int = 0

@onready var weapon_thrower: WeaponThrower = $"../WeaponThrower"
@export var inventory: Inventory

func _init() -> void:
	number_of_slots = GameManager.slots_size
	item_archive.resize(number_of_slots)

func _input(event):
	if event is not InputEventMouseButton or not event.pressed:
		return
		
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			switch_item_slot(-1)
		MOUSE_BUTTON_WHEEL_DOWN:
			switch_item_slot(1)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_slot_1"):
		switch_item_slot_manually(0)
	elif Input.is_action_just_pressed("change_slot_2"):
		switch_item_slot_manually(1)
	elif Input.is_action_just_pressed("change_slot_3"):
		switch_item_slot_manually(2)
	elif Input.is_action_just_pressed("change_slot_4"):
		switch_item_slot_manually(3)
	elif Input.is_action_just_pressed("change_slot_5"):
		switch_item_slot_manually(4)
	elif Input.is_action_just_pressed("change_slot_6"):
		switch_item_slot_manually(5)


# ---------------------------------------------------------
# ADD ITEM → item_detail = path String
# ---------------------------------------------------------
func add_item(item_type: String, item_path: String) -> bool:
	for i in range(number_of_slots):
		print("SLOT DATA: ", item_archive)

		# Slot trống → thêm item
		if not item_archive[i].has("item_type"):
			item_archive[i] = {
				"item_type": item_type,
				"item_detail": [item_path]
			}
			emit_signal("slot_changed", i)
			return true

		# Nếu stack được (không phải weapon)
		elif not is_slot_weapon(i) and item_archive[i]["item_type"] == item_type:
			item_archive[i]["item_detail"].append(item_path)
			emit_signal("slot_changed", i)
			return true
	
	# Không còn slot phù hợp
	return false


func switch_item_slot(offset: int) -> void:
	if item_slot + offset < 0:
		item_slot = 0
	elif item_slot + offset >= number_of_slots:
		item_slot = number_of_slots - 1
	else:
		item_slot += offset

	_equip_current_slot_weapon()

	emit_signal("slot_changed", item_slot)
	print("Switched to slot ", item_slot, "\n", item_archive[item_slot])

func switch_item_slot_manually(slot_num: int) -> void:
	if slot_num < 0 or slot_num >= number_of_slots:
		return
	
	item_slot = slot_num
	_equip_current_slot_weapon()

	emit_signal("slot_changed", item_slot)
	print("Switched to slot ", item_slot, "\n", item_archive[item_slot])

# ---------------------------------------------------------
# EQUIP WEAPON → load resource từ path string
# ---------------------------------------------------------
func _equip_current_slot_weapon():

	GameManager.player.unequip_weapon()
	
	if not is_slot_available():
		info_panel_change.emit(null)
		return

	var item = item_archive[item_slot]
	var path: String = item["item_detail"][0]
	var weapon: WeaponData = load(path)
	info_panel_change.emit(weapon)

	if weapon == null:
		push_error("Failed to load weapon at path: " + path)
		return
		
	GameManager.player.equip_weapon(weapon)


func is_slot_available(slot_index: int = item_slot) -> bool:
	return item_archive[slot_index] != {}


func is_item_storer_full() -> bool:
	for i in range(number_of_slots):
		if not is_slot_available(i):
			return false
	return true


func is_slot_weapon(item_index: int = item_slot) -> bool:
	if item_archive[item_index].has("item_type"):
		return item_archive[item_index]["item_type"].begins_with("weapon_")
	return false


func get_item_type() -> String:
	return item_archive[item_slot]["item_type"]


# ---------------------------------------------------------
# REMOVE ITEM → compare path string
# ---------------------------------------------------------
func remove_item(item_type: String, item_path: String) -> void:
	if item_archive[item_slot]["item_type"] != item_type:
		print("Can't remove a different type of item")
		return

	if item_archive[item_slot]["item_detail"][0] == item_path:
		item_archive[item_slot]["item_detail"].remove_at(0)

		if item_archive[item_slot]["item_detail"].is_empty():
			item_archive[item_slot] = {}

		return


func return_item(item_type: String, item_path: String) -> void:
	if item_archive[item_slot] == {}:
		print("Slot is empty. Can't return item to inventory")
		return
	
	if item_archive[item_slot]["item_type"] != item_type:
		print("Can't return a different type of object to the inventory")
		return

	if item_archive[item_slot]["item_detail"][0] == item_path:
		inventory.insert_item(
			item_archive[item_slot]["item_type"],
			item_archive[item_slot]["item_detail"][0]
		)

		remove_item(
			item_archive[item_slot]["item_type"],
			item_archive[item_slot]["item_detail"][0]
		)

		return


func show_slots() -> void:
	print("List of slots:")
	for item_index in len(item_archive):
		if is_slot_weapon(item_index):
			print(item_index, ": ", item_archive[item_index])
		elif item_archive[item_index].is_empty():
			print(item_index, ": ", item_archive[item_index])
		else:
			print(item_index, ": ",
			item_archive[item_index]["item_type"],
			": size: ", item_archive[item_index]["item_detail"].size())
	print("\n")


func save_slots() -> void:
	GameManager.slots_data = item_archive.duplicate(true)
	GameManager.save_slots_data()
	for i in range(number_of_slots):
		emit_signal("slot_changed", i)
	switch_item_slot(item_slot)


func initialize_slots():
	item_archive = GameManager.slots_data.duplicate(true)

	if item_archive.is_empty():
		item_archive.resize(number_of_slots)
		for i in range(number_of_slots):
			item_archive[i] = {}
	
	for i in range(number_of_slots):
		emit_signal("slot_changed", i)

	_equip_current_slot_weapon()
	emit_signal("slot_changed", item_slot)

	print("itemtorer initialized:", item_archive)
	
func move(from: int, to: int):
	if from == to:
		return
	
	if from < 0 or from >= number_of_slots or to < 0 or to >= number_of_slots:
		printerr(" Invalid slot indices: from=", from, " to=", to)
		return
	
	# Swap
	var temp = item_archive[to]
	item_archive[to] = item_archive[from]
	item_archive[from] = temp
	
	if from == item_slot:
		item_slot = to
	elif to == item_slot:
		item_slot = from
	
	emit_signal("slot_changed", from)
	emit_signal("slot_changed", to)
	
	_equip_current_slot_weapon()
	GameManager.player.item_storer.save_slots()
	debug_slots()
	
func debug_slots():
	print("\n=== DEBUG HOTBAR SLOTS ===")
	for i in range(item_archive.size()):
		print(i, ": ", item_archive[i])
	print("==========================\n")
	
func destroy_current_item():
	print("itemtorer: Destroying item in slot ", item_slot)
	
	item_archive[item_slot] = {}
	
	save_slots()
	
	_equip_current_slot_weapon()
	
	item_destroyed.emit(item_slot)
