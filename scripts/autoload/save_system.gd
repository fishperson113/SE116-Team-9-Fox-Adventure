extends Node

## Save system for persistent checkpoint data

const SAVE_FILE = "user://checkpoint_save.dat"

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

# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

# Delete save file
func delete_save_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE)
		print("Save file deleted")
