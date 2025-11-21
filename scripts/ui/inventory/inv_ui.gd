extends Control
class_name InvUI

var item_type: String = ""
var item_detail: Dictionary = {}
var quantity: int = 0

@onready var qty = $Label
@export var item_storer: ItemStorer

func update_inventory_ui():
	var slots = $GridContainer.get_children()
	print("Slots found:", slots.size())
	print("🔄 Updating inventory UI...")

	if item_storer == null:
		print("❌ InvUI không có item_storer")
		return

	print("📦 Inventory archive:", item_storer.items_archive)
	var archive = GameManager.player.inventory.item_archive

	for s in slots:
		s.clear_slot()

	for i in range(min(archive.size(), slots.size())):
		var data = archive[i]
		if data == {}:
			continue

		var item_type = data["item_type"]
		var detail = data["item_detail"]
		var count = data["count"]

		var texture = load(detail["texture_path"])
		var slot = slots[i]

		slot.set_item(texture, item_type, detail, count)

		slot.quantity = count
		slot.qty.text = str(count)
		slot.qty.visible = true
		
func clear_slot():
	item_type = ""
	item_detail = {}
	quantity = 0
	qty.text = ""
	qty.visible = false

func set_item(tex, type, detail, count):
	item_type = type
	item_detail = detail
	quantity = count
	qty.text = str(count)
	qty.visible = true
