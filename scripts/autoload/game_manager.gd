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

func _ready() -> void:
	# Load checkpoint data when game starts
	load_tutorial_progress()
	load_checkpoint_data()
	load_inventory_data()
	load_slots_data()
	load_level_progress()
	initialize_systems()
	pass
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
	for i in range(slots_data.size()):
		if not slots_data[i].has("item_type"):
			continue
		
		if not slots_data[i]["item_type"].begins_with("weapon_"):
			continue
		
		for j in range(slots_data[i]["item_detail"].size()):
			slots_data[i]["item_detail"][j] = slots_data[i]["item_detail"][j].resource_path
			
	SaveSystem.save_slots_data(slots_data)

func load_slots_data() -> void:
	var slots = SaveSystem.load_slots_data()
	if not slots.is_empty():
		for i in range(slots.size()):
			if not slots[i].has("item_type"):
				continue
			
			if not slots[i]["item_type"].begins_with("weapon_"):
				continue
			
			for j in range(slots[i]["item_detail"].size()):
				slots[i]["item_detail"][j] = load(slots[i]["item_detail"][j])
		slots_data = slots;
		print("Slots data loaded from inventory file")

func clear_slots_data() -> void:
	slots_data.clear()
	SaveSystem.delete_slots_file()
	print("All inventory data cleared")

func save_inventory_data() -> void:
	for i in range(inventory_data.size()):
		if not inventory_data[i]["item_type"].begins_with("weapon_"):
			continue
			
		for j in range(inventory_data[i]["item_detail"].size()):
			inventory_data[i]["item_detail"][j] = inventory_data[i]["item_detail"][j].resource_path
	
	SaveSystem.save_inventory_data(inventory_data)

func load_inventory_data() -> void:
	var inventory = SaveSystem.load_inventory_data()
	if not inventory.is_empty():
		for i in range(inventory.size()):
			if not inventory[i]["item_type"].begins_with("weapon_"):
				continue
				
			for j in range(inventory[i]["item_detail"].size()):
				inventory[i]["item_detail"][j] = load(inventory[i]["item_detail"][j])
		
		inventory_data = inventory;
		print("Inventory data loaded from inventory file")

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
	else:
		return false
	
	return true

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
#func get_tutorial_progress() -> bool:
#	return is_tutorial_finished
