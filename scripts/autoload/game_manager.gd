extends Node

#target portal name is the name of the portal to which the player will be teleported
var target_portal_name: String = ""
# Checkpoint system variables
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}

var current_stage = ""
var player: Player = null
var player_has_blade: bool = false

# Lobby progress
var is_tutorial_finished = false

# Level progress
var current_level: int = 0
var max_level_unlocked: int = 1

#Slots that store items and weapons on use
var slots_size = 6
var slots_data: Array[Dictionary] = converted_empty_slots()
#Inventory that stores items and weapons overall
var inventory_data: Array[Dictionary] = []

# How many blades are available?
var blade_count: int = 50
var coin_count:int = 50

# --- CẤU HÌNH MATERIAL MẶC ĐỊNH ---
const DEFAULT_MATERIALS: Dictionary = {
	"copper": 50,
	"iron": 50,
	"gold": 50
}

var materials_wallet: Dictionary = DEFAULT_MATERIALS.duplicate()

#Crafting cost
var crafting_cost: int = 10
var material_crafting_cost: int = 5
var is_paid_coin:bool =false
var is_paid_ore:bool =false
var pending_material_id: String = ""
var pending_material_amount: int = 0
# Signals
signal modifyBlade
signal coinChange
signal materialChange
signal weaponDurabilityChange

func _ready() -> void:
	# Load checkpoint data when game starts
	load_tutorial_progress()
	load_checkpoint_data()
	load_inventory_data()
	load_slots_data()
	load_level_progress()
	load_resources_data()
	pass

func has_material(material_id: String, amount: int) -> bool:
	return int(materials_wallet.get(material_id, 0)) >= amount

func add_material(material_id: String, amount: int) -> void:
	if material_id not in materials_wallet:
		materials_wallet[material_id] = 0
	
	materials_wallet[material_id] = int(materials_wallet[material_id] + amount)
	
	materialChange.emit()
	print("Added %d %s. Total: %d" % [amount, material_id, materials_wallet[material_id]])

func pay_material_fee(material_id: String, amount: int) -> bool:
	if is_paid_ore:
		return true
		
	if not has_material(material_id, amount):
		print("Không đủ material: " + material_id)
		return false
	
	materials_wallet[material_id] = int(materials_wallet[material_id] - amount)
	
	pending_material_id = material_id
	pending_material_amount = amount
	is_paid_ore = true
	
	materialChange.emit()
	save_resources_data()
	print("Đã tạm trừ %d %s. (Is Paid Ore: True)" % [amount, material_id])
	return true
	
func pay_entry_fee() -> bool:
	if is_paid_coin:
		return true

	if coin_count >= crafting_cost:
		remove_coins(crafting_cost)
		is_paid_coin = true
		save_resources_data()
		print("GameManager: Đã mua vé craft. (Has Ticket: True)")
		return true
	
	print("GameManager: Không đủ tiền.")
	return false
	
func refund_all_fees() -> void:
	var need_save = false
	
	if is_paid_coin:
		add_coins(crafting_cost)
		is_paid_coin = false
		need_save = true
		print("Đã hoàn tiền Coin.")
		
	if is_paid_ore:
		if pending_material_id != "":
			materials_wallet[pending_material_id] = int(materials_wallet.get(pending_material_id, 0) + pending_material_amount)
			materialChange.emit()
			
		pending_material_id = ""
		pending_material_amount = 0
		is_paid_ore = false
		need_save = true
		print("Đã hoàn trả Ore.")

	if need_save:
		save_resources_data()

func finalize_crafting() -> void:
	if is_paid_coin or is_paid_ore:
		is_paid_coin = false
		is_paid_ore = false
		pending_material_id = ""
		pending_material_amount = 0
		print("Craft thành công! Giao dịch hoàn tất (Không hoàn tiền).")

func initialize_systems():
	await get_tree().process_frame

	if player and player.item_storer:
		player.item_storer.initialize_slots()
func collect_blade():
	if player_has_blade:
		return

	player_has_blade = true
	
	if player != null:
		player.collected_blade()
		print("GameManager: Player has collected the blade!")
	else:
		printerr("GameManager: Could not find player node to give blade to.")

#change stage by path and target portal name
func change_stage(stage_path: String, _target_portal_name: String = "") -> void:
	save_resources_data()
	target_portal_name = _target_portal_name
	#change scene to stage path
	get_tree().change_scene_to_file(stage_path)

func load_current_stage(level: int) -> void:
	current_level = level

#call from dialogic
func call_from_dialogic(msg:String = ""):
	#Dialogic.VAR["PlayerScore"] = 30
	print("Call from dialogic " + msg)

#respawn at portal or door
func respawn_at_portal() -> bool:
	if not target_portal_name.is_empty():
		player.global_position = current_stage.find_child(target_portal_name).global_position
		GameManager.target_portal_name = ""
		return true
	return false

# Checkpoint system functions
func save_checkpoint(checkpoint_id: String) -> void:
	current_checkpoint_id = checkpoint_id
	var player_state_dict: Dictionary = player.save_state()
	checkpoint_data[checkpoint_id] = {
		"player_state":player_state_dict,
		"stage_path": current_level
	}
	print("Checkpoint saved: ", checkpoint_id)

func load_checkpoint(checkpoint_id: String) -> Dictionary:
	if checkpoint_id in checkpoint_data:
		return checkpoint_data[checkpoint_id]
	return {}

#respawn at checkpoint
func respawn_at_checkpoint() -> void:
	if current_checkpoint_id.is_empty():
		print("No checkpoint available")
		return
	
	var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
	if checkpoint_info.is_empty():
		print("Checkpoint data not found")
		return
	
	# Load the stage if different
	var checkpoint_stage = checkpoint_info.get("stage_path")
	
	if current_level != checkpoint_stage:
		return
		
	# Can change stage if different but not implemented yet to test
	#	change_stage(checkpoint_stage, "")
	#	# Wait for scene to load
	#	await get_tree().process_frame

	if player != null:
		var player_state: Dictionary = checkpoint_info.get("player_state")
		if player_state == null:
			return
		player.load_state(player_state)
		print("Player respawned at checkpoint: ", current_checkpoint_id)
	else:
		print("Player not found for respawn")

#check if there is a checkpoint
func has_checkpoint() -> bool:
	return not current_checkpoint_id.is_empty()

# Save checkpoint data to persistent storage
func save_checkpoint_data() -> void:
	var save_data = {
		"current_checkpoint_id": current_checkpoint_id,
		"checkpoint_data": checkpoint_data
	}
	SaveSystem.save_checkpoint_data(save_data)
	save_resources_data()

# Load checkpoint data from persistent storage
func load_checkpoint_data() -> void:
	var save_data = SaveSystem.load_checkpoint_data()
	if not save_data.is_empty():
		current_checkpoint_id = save_data.get("current_checkpoint_id", "")
		checkpoint_data = save_data.get("checkpoint_data", {})
		print("Checkpoint data loaded from save file")

# Clear all checkpoint data
func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()
	print("All checkpoint data cleared")

func save_slots_data() -> void:
	SaveSystem.save_slots_data(slots_data)

func load_slots_data() -> void:
	var slots = SaveSystem.load_slots_data()
	if not slots.is_empty():
		slots_data = slots
		print("Slots data loaded from file")

func clear_slots_data() -> void:
	slots_data.clear()
	SaveSystem.delete_slots_file()
	print("All inventory data cleared")

func save_inventory_data() -> void:
	SaveSystem.save_inventory_data(inventory_data)

func load_inventory_data() -> void:
	var inventory = SaveSystem.load_inventory_data()
	if not inventory.is_empty():
		inventory_data = inventory
		print("Inventory data loaded from file")

func clear_inventory_data() -> void:
	inventory_data.clear()
	SaveSystem.delete_inventory_file()
	print("All inventory data cleared")

func converted_empty_slots() -> Array[Dictionary]:
	var empty_slots: Array[Dictionary]
	empty_slots.resize(slots_size)
	for i in range(slots_size):
		empty_slots[i] = {}
	return empty_slots

func check_object_type(item_one, item_two) -> bool:
	if item_one is WeaponData and item_two is WeaponData:
		return item_one.resource_path == item_two.resource_path
	elif item_one is WeaponMaterialData and item_two is WeaponMaterialData:
		return item_one.id == item_two.id
	return false

# Level progress functions
func unlock_level() -> void:
	if current_level + 1 > max_level_unlocked:
		max_level_unlocked = current_level + 1
		save_level_progress()
		print("Level unlocked: ", current_level + 1)
	else:
		print("Not reached max level. Can't unlock new level")

func is_level_unlocked(level_num: int) -> bool:
	return level_num <= max_level_unlocked

func save_level_progress() -> void:
	SaveSystem.save_level_progress(max_level_unlocked)

func load_level_progress() -> void:
	max_level_unlocked = SaveSystem.load_level_progress()
	print("Level progress loaded: ", max_level_unlocked)

func reset_level_progress() -> void:
	max_level_unlocked = 1
	SaveSystem.delete_level_progress_file()
	print("Level progress reset")

func mark_tutorial_finished() -> void:
	is_tutorial_finished = true
	SaveSystem.save_tutorial_progress(is_tutorial_finished)

func load_tutorial_progress() -> void:
	var tutorial_progress: Dictionary = SaveSystem.load_tutorial_progress()
	if not tutorial_progress.is_empty():
		is_tutorial_finished = tutorial_progress["is_tutorial_finished"]
		print("Tutorial progress loaded")

func add_blades(number_of_blades: int) -> void:
	blade_count += number_of_blades
	modifyBlade.emit()

func remove_blades(number_of_blades: int) -> void:
	blade_count -= number_of_blades
	if blade_count < 0:
		blade_count = 0
	modifyBlade.emit()
func add_coins(number_of_coins: int) -> void:
	coin_count += number_of_coins
	coinChange.emit()

func remove_coins(number_of_coins: int) -> void:
	coin_count -= number_of_coins
	coinChange.emit()
#func get_tutorial_progress() -> bool:
#	return is_tutorial_finished

func save_resources_data() -> void:
	var resources_data = {
		"coin_count": coin_count,
		"blade_count": blade_count,
		"materials_wallet": materials_wallet
	}
	SaveSystem.save_resources_data(resources_data)
	print("Resources data saved (Coin, Blade, Materials)")

func load_resources_data() -> void:
	var resources = SaveSystem.load_resources_data()
	
	if not resources.is_empty():
		coin_count = int(resources.get("coin_count", 0))
		blade_count = int(resources.get("blade_count", 0))
		
		materials_wallet = DEFAULT_MATERIALS.duplicate()
		var saved_wallet = resources.get("materials_wallet", {})
		
		for key in saved_wallet:
			if key in materials_wallet:
				materials_wallet[key] = int(saved_wallet[key])
	else:
		materials_wallet = DEFAULT_MATERIALS.duplicate()
		
	coinChange.emit()
	modifyBlade.emit()
	materialChange.emit()
		
	print("Resources loaded: Coins=%d, Blades=%d, Mats=%s" % [coin_count, blade_count, str(materials_wallet)])

func clear_resources_data() -> void:
	coin_count = 0
	blade_count = 0
	materials_wallet = DEFAULT_MATERIALS.duplicate()
	
	SaveSystem.delete_resources_file()
	
	# Cập nhật UI về 0
	coinChange.emit()
	modifyBlade.emit()
	materialChange.emit()
	print("All resources data cleared")
