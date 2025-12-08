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


func load_icon(item_type: String, item_detail_list := []) -> Texture2D:
	if item_type.begins_with("weapon_"):
		# item_detail_list giờ chứa STRING PATH
		if item_detail_list.size() > 0 and item_detail_list[0] is String:
			var weapon_path: String = item_detail_list[0]

			if ResourceLoader.exists(weapon_path):
				var weapon: WeaponData = load(weapon_path)

				if weapon and weapon.png_path != "":
					if FileAccess.file_exists(weapon.png_path):
						var img := Image.load_from_file(weapon.png_path)
						if img:
							return ImageTexture.create_from_image(img)
						printerr("⚠ Failed to load PNG from: ", weapon.png_path)
						return null
					printerr("⚠ PNG not found at: ", weapon.png_path)
					return null

			printerr("⚠ Invalid weapon path: ", weapon_path)
			return null

		printerr("⚠ item_detail_list does not contain weapon path")
		return null

	# Normal item → load icon mặc định
	var default_path := "res://assets/ui/icons/%s.png" % item_type
	if ResourceLoader.exists(default_path):
		return load(default_path)

	printerr("⚠ Default icon not found for: ", item_type)
	return null


func highlight_slot(index: int):
	for i in range(slots.size()):
		slots[i].highlight(i == index)

func _on_slot_changed(new_slot: int):
	current_hotbar_slot = new_slot
	highlight_slot(new_slot)
