extends Node

## Save system for persistent checkpoint data

const SAVE_FILE = "user://checkpoint_save.dat"
const SLOTS_FILE = "user://slots_save.dat"
const INVENTORY_FILE = "user://inventory_save.dat"

# Save checkpoint data to file
func save_checkpoint_data(data: Dictionary) -> void:
	#TODO: save checkpoint data to save file
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		# Chuyển đổi Dictionary thành một chuỗi JSON
		var json_string = JSON.stringify(data, "\t") # Dùng "\t" để format cho dễ đọc
		
		# Ghi chuỗi JSON vào file
		file.store_string(json_string)
		
		# Đóng file (quan trọng)
		file.close()
		print("Checkpoint data saved successfully.")
	else:
		printerr("An error occurred when trying to save the file.")
	pass

# Load checkpoint data from file
func load_checkpoint_data() -> Dictionary:
	#TODO: load checkpoint data from save file
	
	# Kiểm tra file có tồn tại không trước khi đọc
	if not has_save_file():
		return {}

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		# Đọc toàn bộ nội dung file dưới dạng text
		var content = file.get_as_text()
		file.close()
		
		# Chuyển đổi chuỗi JSON ngược lại thành Dictionary
		var json = JSON.new()
		var error = json.parse(content)
		
		# Nếu có lỗi khi parse (ví dụ file bị hỏng), trả về dictionary rỗng
		if error != OK:
			printerr("Error parsing JSON file: ", error)
			return {}
			
		# Trả về dữ liệu đã được parse
		return json.get_data()
	
	printerr("An error occurred when trying to open the save file.")
	return {}
	pass

func save_slots_data(data: Array[Dictionary]) -> void:
	#TODO: save checkpoint data to save file
	var file = FileAccess.open(SLOTS_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t") # Dùng "\t" để format cho dễ đọc
		file.store_string(json_string)
		file.close()
		print("Slots data saved successfully.")
	else:
		printerr("An error occurred when trying to save the file.")
	pass

func load_slots_data() -> Array[Dictionary]:
	# Kiểm tra file có tồn tại không trước khi đọc
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
	
	printerr("An error occurred when trying to open the save file.")
	return converted_empty_slots()

func save_inventory_data(data: Array[Dictionary]) -> void:
	#TODO: save checkpoint data to save file
	var file = FileAccess.open(INVENTORY_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t") # Dùng "\t" để format cho dễ đọc
		file.store_string(json_string)
		file.close()
		print("Inventory data saved successfully.")
	else:
		printerr("An error occurred when trying to save the file.")
	pass

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
	
	printerr("An error occurred when trying to open the save file.")
	return []
	
# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

# Delete save file
func delete_save_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE)
		print("Save file deleted")

func has_slots_file() -> bool:
	return FileAccess.file_exists(SLOTS_FILE)

# Delete save file
func delete_slots_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SLOTS_FILE)
		print("Slots file deleted")

func has_inventory_file() -> bool:
	return FileAccess.file_exists(INVENTORY_FILE)

# Delete save file
func delete_inventory_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(INVENTORY_FILE)
		print("Inventory file deleted")

func converted_empty_slots() -> Array[Dictionary]:
	var empty_slots: Array[Dictionary]
	empty_slots.resize(GameManager.slots_size)
	for i in range(GameManager.slots_size):
		empty_slots[i] = {
			"is_weapon": false,
			"item_type": "none",
			"number_of_item": 0
		}
	return empty_slots
