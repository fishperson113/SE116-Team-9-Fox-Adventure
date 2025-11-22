# SaveSystem.gd
extends Node

## Save system for persistent checkpoint data

const SAVE_FILE = "user://checkpoint_save.dat"
const SLOTS_FILE = "user://slots_save.dat"
const INVENTORY_FILE = "user://inventory_save.dat"
const TUTORIAL_PROGRESS_FILE = "user://tutorial_progress.dat"
const LEVEL_PROGRESS_FILE = "user://level_progress.dat"

# Save checkpoint data to file
func save_checkpoint_data(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
		print("Checkpoint data saved successfully.")
	else:
		printerr("An error occurred when trying to save the checkpoint file.")

# Load checkpoint data from file
func load_checkpoint_data() -> Dictionary:
	if not has_save_file():
		return {}

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		
		if error != OK:
			printerr("Error parsing JSON file: ", error)
			return {}
			
		return json.get_data()
	
	printerr("An error occurred when trying to open the save file.")
	return {}

# Save slots data to file
func save_slots_data(data: Array[Dictionary]) -> void:
	var file = FileAccess.open(SLOTS_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
		print("Slots data saved successfully.")
	else:
		printerr("An error occurred when trying to save the slots file.")

# Load slots data from file
func load_slots_data() -> Array[Dictionary]:
	if not has_slots_file():
		return converted_empty_slots()

	var file = FileAccess.open(SLOTS_FILE, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		
		if error != OK:
			printerr("Error parsing JSON file: ", error)
			return converted_empty_slots()
		
		var data = json.get_data()
		if typeof(data) != TYPE_ARRAY:
			printerr("Expected array in JSON, got ", typeof(data), "instead")
			return converted_empty_slots()
		
		var typed_data: Array[Dictionary] = []
		for element in data:
			if typeof(element) == TYPE_DICTIONARY:
				typed_data.append(element)
			else:
				printerr("Invalid element in JSON array")
				return converted_empty_slots()
		
		return typed_data
	
	printerr("An error occurred when trying to open the slots file.")
	return converted_empty_slots()

# Save inventory data to file
func save_inventory_data(data: Array[Dictionary]) -> void:
	var file = FileAccess.open(INVENTORY_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
		print("Inventory data saved successfully.")
	else:
		printerr("An error occurred when trying to save the inventory file.")

# Load inventory data from file
func load_inventory_data() -> Array[Dictionary]:
	if not has_inventory_file():
		return []

	var file = FileAccess.open(INVENTORY_FILE, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		
		if error != OK:
			printerr("Error parsing JSON file: ", error)
			return []
		
		var data = json.get_data()
		if typeof(data) != TYPE_ARRAY:
			printerr("Expected array in JSON, got ", typeof(data), "instead")
			return []
		
		var typed_data: Array[Dictionary] = []
		for element in data:
			if typeof(element) == TYPE_DICTIONARY:
				typed_data.append(element)
			else:
				printerr("Invalid element in JSON array")
				return []
		
		return typed_data
	
	printerr("An error occurred when trying to open the inventory file.")
	return []

# Save level progress to file
func save_level_progress(max_level: int) -> void:
	var file = FileAccess.open(LEVEL_PROGRESS_FILE, FileAccess.WRITE)
	if file:
		var data = {"max_level_unlocked": max_level}
		var json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
		print("Level progress saved: ", max_level)
	else:
		printerr("An error occurred when trying to save level progress.")

# Load level progress from file
func load_level_progress() -> int:
	if not has_level_progress_file():
		return 1  # Default: chỉ level 1 được mở

	var file = FileAccess.open(LEVEL_PROGRESS_FILE, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		
		if error != OK:
			printerr("Error parsing level progress JSON: ", error)
			return 1
		
		var data = json.get_data()
		if typeof(data) == TYPE_DICTIONARY and "max_level_unlocked" in data:
			return int(data["max_level_unlocked"])
		else:
			printerr("Invalid level progress data format")
			return 1
	
	printerr("An error occurred when trying to open level progress file.")
	return 1

# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

# Delete save file
func delete_save_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE)
		print("Save file deleted")

# Check if slots file exists
func has_slots_file() -> bool:
	return FileAccess.file_exists(SLOTS_FILE)

# Delete slots file
func delete_slots_file() -> void:
	if has_slots_file():
		DirAccess.remove_absolute(SLOTS_FILE)
		print("Slots file deleted")

# Check if inventory file exists
func has_inventory_file() -> bool:
	return FileAccess.file_exists(INVENTORY_FILE)

# Delete inventory file
func delete_inventory_file() -> void:
	if has_inventory_file():
		DirAccess.remove_absolute(INVENTORY_FILE)
		print("Inventory file deleted")

# Check if level progress file exists
func has_level_progress_file() -> bool:
	return FileAccess.file_exists(LEVEL_PROGRESS_FILE)

# Delete level progress file
func delete_level_progress_file() -> void:
	if has_level_progress_file():
		DirAccess.remove_absolute(LEVEL_PROGRESS_FILE)
		print("Level progress file deleted")

func has_tutorial_progress_file() -> bool:
	return FileAccess.file_exists(TUTORIAL_PROGRESS_FILE)

func delete_tutorial_progress_file() -> void:
	if has_tutorial_progress_file():
		DirAccess.remove_absolute(TUTORIAL_PROGRESS_FILE)
		print("Tutorial file deleted")

# Convert empty slots
func converted_empty_slots() -> Array[Dictionary]:
	var empty_slots: Array[Dictionary]
	empty_slots.resize(GameManager.slots_size)
	for i in range(GameManager.slots_size):
		empty_slots[i] = {}
	return empty_slots

func save_tutorial_progress(is_finished: bool) -> void:
	var file = FileAccess.open(TUTORIAL_PROGRESS_FILE, FileAccess.WRITE)
	if file:
		var data = {"is_tutorial_finished": is_finished}
		var json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()
		print("Tutorial progress is saved!")
	else:
		printerr("An error occurred when trying to save level progress.")
		
func load_tutorial_progress() -> Dictionary:
	if not has_tutorial_progress_file():
		return {}

	var file = FileAccess.open(TUTORIAL_PROGRESS_FILE, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(content)
		
		if error != OK:
			printerr("Error parsing JSON file: ", error)
			return {}
			
		return json.get_data()
	
	printerr("An error occurred when trying to open the save file.")
	return {}
