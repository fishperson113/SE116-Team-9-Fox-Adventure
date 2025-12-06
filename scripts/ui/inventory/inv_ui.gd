extends Control
class_name InvUI

@onready var slots := $Panel/MarginContainer/GridContainer.get_children()

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
		var icon := load_icon(item_type)

		slots[i].set_item(icon, item_type, item_detail_list, count)


func load_icon(item_type: String) -> Texture2D:
	var path := "res://ui/icons/%s.png" % item_type
	if ResourceLoader.exists(path):
		return load(path)
	else:
		print("⚠️ Không tìm thấy icon cho:", item_type)
		return null
