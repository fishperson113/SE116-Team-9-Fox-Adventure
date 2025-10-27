extends Node
class_name ItemStorer

var number_of_slots: int = 6
var items_archive: Array[Dictionary]

var item_slot: int = 0

@onready var weapon_thrower: WeaponThrower = $"../WeaponThrower"
@export var inventory: Inventory

func _init() -> void:
	items_archive.resize(number_of_slots)

func _ready() -> void:
	for i in range(number_of_slots):
		items_archive[i] = {
			"is_weapon": false,
			"item_type": "none",
			"number_of_item": 0
		}
	change_item()
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch_item"):
		switch_item_slot()

func add_item(is_weapon: bool, item_type: String) -> bool:
	if items_archive[item_slot]["item_type"] != "none":
		if items_archive[item_slot]["is_weapon"] != is_weapon or items_archive[item_slot]["item_type"] != item_type:
			print("Not the same item or weapon type")
			return false
		items_archive[item_slot]["number_of_item"] += 1
		change_item()
		return true
	
	items_archive[item_slot]["is_weapon"] = is_weapon
	items_archive[item_slot]["item_type"] = item_type
	items_archive[item_slot]["number_of_item"] = 1
	change_item()
	return true

func change_item() -> void:
	if is_slot_weapon() and is_slot_available():
		weapon_thrower.change_projectile(items_archive[item_slot]["item_type"])
	else:
		weapon_thrower.change_projectile("none")

func switch_item_slot() -> void:
	if item_slot + 1 >= number_of_slots:
		item_slot = 0
	else:
		item_slot += 1
	change_item()
	print("Switched to slot ", item_slot, "\n", items_archive[item_slot])

func is_slot_available() -> bool:
	return items_archive[item_slot]["number_of_item"] > 0

func is_slot_weapon() -> bool:
	return items_archive[item_slot]["is_weapon"]

func get_item_type() -> String:
	return items_archive[item_slot]["item_type"]

func reduce_item() -> void:
	items_archive[item_slot]["number_of_item"] -= 1
	if items_archive[item_slot]["number_of_item"] == 0:
		items_archive[item_slot]["is_weapon"] = false
		items_archive[item_slot]["item_type"] = "none"
	print("Item reduced: ", item_slot, "\n", items_archive[item_slot])

func return_item() -> void:
	if items_archive[item_slot]["item_type"] == "none":
		print("Slot is empty. Can't return item to inventory")
		return
	inventory.insert_item(
		items_archive[item_slot]["is_weapon"],
		items_archive[item_slot]["item_type"]
		)
	reduce_item()
	change_item()
	pass
