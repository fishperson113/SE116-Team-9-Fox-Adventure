extends Control
class_name InvUI

@onready var slots := $Panel/MarginContainer/GridContainer.get_children()
func _ready() -> void:
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


func load_icon(item_type: String, item_detail_list := []) -> Texture2D:

	if item_type.begins_with("weapon_"):
		if item_detail_list.size() > 0 and item_detail_list[0] is WeaponData:
			var weapon: WeaponData = item_detail_list[0]
			var icon_path := weapon.png_path

			if icon_path != "" and FileAccess.file_exists(icon_path):
				var img := Image.load_from_file(icon_path)
				if img:
					return ImageTexture.create_from_image(img)

				printerr("⚠ Failed to load image from file: ", icon_path)
				return null

			printerr("⚠ Weapon icon not found at: ", icon_path)
			return null

		printerr("⚠ Invalid weapon data for: ", item_type)
		return null

	var default_path := "res://ui/icons/%s.png" % item_type

	if ResourceLoader.exists(default_path):
		return load(default_path)

	printerr("⚠ Default icon not found for item_type: ", item_type)
	return null
