extends Resource
class_name WeaponData

# Đường dẫn đến file icon .png đã render
@export var icon_path: String

# Công thức để tái tạo lại vũ khí khi cần
@export var parts_list: Array[Dictionary] = []

# Chỉ số đã tính toán
@export var stats: Dictionary = {}

# Tên vũ khí (có thể cho người dùng đặt)
@export var display_name: String = "Crafted Weapon"
