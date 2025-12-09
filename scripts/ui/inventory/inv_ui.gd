extends Control
class_name InvUI

@onready var slots := $Panel/MarginContainer/GridContainer.get_children()
var current_hotbar_slot := -1

func _ready() -> void:
	GameManager.player.inventory.inventory_changed.connect(update_inventory_ui)
	GameManager.player.inventory.item_storer.slot_changed.connect(_on_slot_changed)
	update_inventory_ui()
	
func update_inventory_ui():
	var archive = GameManager.player.inventory.item_archive

	# Reset toàn bộ slot trước
	for slot in slots:
		slot.clear_slot()

	# Loop 6 slot cố định
	for i in range(min(archive.size(), slots.size())):
		var item_data = archive[i]
		
		# Slot trống trong BE --> skip
		if item_data.is_empty():
			continue

		var item_type: String = item_data["item_type"]
		var item_detail_list = item_data["item_detail"]
		
		# Nếu mảng item_detail rỗng → slot trống
		if item_detail_list.size() == 0:
			continue

		var count :int = item_detail_list.size()
		var icon := load_icon(item_type, item_detail_list)

		slots[i].set_item(icon, item_type, item_detail_list, count)


func load_icon(item_type: String, item_detail_list: Array) -> Texture2D:
		return _get_weapon_icon(item_detail_list)


func highlight_slot(index: int):
	for i in range(slots.size()):
		slots[i].highlight(i == index)

func _on_slot_changed(new_slot: int):
	current_hotbar_slot = new_slot
	highlight_slot(new_slot)

func _get_weapon_icon(item_detail_list: Array) -> Texture2D:
	# 1. Load data
	var weapon_data = _load_weapon_data(item_detail_list)
	if not weapon_data:
		return null
	
	# 2. Load texture từ data
	return _load_texture_from_disk(weapon_data.png_path)

func _load_weapon_data(item_detail_list: Array) -> WeaponData:
	if item_detail_list.is_empty() or not (item_detail_list[0] is String):
		printerr("⚠ Item detail list invalid or empty")
		return null
		
	var weapon_path: String = item_detail_list[0]
	
	if not ResourceLoader.exists(weapon_path):
		printerr("⚠ Invalid weapon path: ", weapon_path)
		return null
		
	return load(weapon_path) as WeaponData


# Helper: Load ảnh từ đường dẫn file (External/User path) -> ImageTexture
func _load_texture_from_disk(file_path: String) -> Texture2D:
	if file_path == "":
		return null

	if not FileAccess.file_exists(file_path):
		printerr("⚠ PNG file not found at: ", file_path)
		return null

	var img := Image.load_from_file(file_path)
	if img:
		return ImageTexture.create_from_image(img)
	
	printerr("⚠ Failed to create image from: ", file_path)
	return null
