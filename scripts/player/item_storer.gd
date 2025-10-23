extends Node
class_name ItemStorer

var number_of_slots: int = 6
var items_archive: Array[Dictionary]

var item_slot: int = 0

@onready var weapon_thrower: WeaponThrower = $"../WeaponThrower"

func _init() -> void:
	items_archive.resize(number_of_slots)

func _ready() -> void:
	for i in range(number_of_slots):
		items_archive[i] = {
			"is_weapon": false,
			"item_type": -1,
			"number_of_item": 0
		}
	#Thứ tự các tham số là: thứ tự slot,
	#						có phải là weapon?,
	#						loại item/weapon, -1 là không có
	#						số lượng item/weapon còn lại
	add_item(0, false, -1, 0)
	add_item(1, true, 0, 2)
	add_item(2, false, -1, 0)
	add_item(3, true, 1, 3)
	add_item(4, false, -1, 0)
	add_item(5, false, -1, 0)
	change_item()
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_item"):
		switch_item_slot()
	elif Input.is_action_just_pressed("increase_item"):
		increase_item()

func add_item(slot: int, is_weapon: bool, item_type: int, number: int) -> void:
	items_archive[slot]["is_weapon"] = is_weapon
	items_archive[slot]["item_type"] = item_type
	items_archive[slot]["number_of_item"] = number

func change_item() -> void:
	if is_slot_weapon() and is_slot_available():
		weapon_thrower.change_projectile(items_archive[item_slot]["item_type"])
	else:
		weapon_thrower.change_projectile(-1)
	print("Slot switched: ", item_slot, "\n", items_archive[item_slot])

func switch_item_slot() -> void:
	if item_slot + 1 >= number_of_slots:
		item_slot = 0
	else:
		item_slot += 1
	change_item()

func is_slot_available() -> bool:
	return items_archive[item_slot]["number_of_item"] > 0

func is_slot_weapon() -> bool:
	return items_archive[item_slot]["is_weapon"]

func get_item_type() -> int:
	return items_archive[item_slot]["item_type"]

func increase_item() -> void:
	if items_archive[item_slot]["item_type"] == -1:
		print("No item in the slot")
		return
	items_archive[item_slot]["number_of_item"] += 1
	print("Item increased: ", item_slot, "\n", items_archive[item_slot])

func reduce_item() -> void:
	items_archive[item_slot]["number_of_item"] -= 1
	if items_archive[item_slot]["number_of_item"] == 0:
		items_archive[item_slot]["is_weapon"] = false
		items_archive[item_slot]["item_type"] = -1
	print("Item reduced: ", item_slot, "\n", items_archive[item_slot])
