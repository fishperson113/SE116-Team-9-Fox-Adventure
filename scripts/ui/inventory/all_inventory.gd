extends Control
class_name AllInventory

@export var slot_scene: PackedScene

@onready var grid := $NinePatchRect/GridContainer
var slots: Array = []
var is_open := false


func _ready():
	self.visible = false     # inventory ẩn khi bắt đầu

	for c in grid.get_children():
		c.queue_free()

	slots.clear()

	for i in range(16):
		create_new_slot()

	refresh()


func _input(event):
	if event.is_action_pressed("open_inventory"):
		if is_open:
			close_inventory()
		else:
			open_inventory()


func open_inventory():
	self.visible = true
	is_open = true


func close_inventory():
	self.visible = false
	is_open = false


func create_new_slot():
	var s = slot_scene.instantiate()
	grid.add_child(s)
	slots.append(s)
	return s


func refresh():
	if GameManager.player == null:
		print("Không tìm thấy player")
		return

	var archive = GameManager.player.inventory.item_archive

	for s in slots:
		s.clear_slot()

	for i in range(min(archive.size(), slots.size())):
		var data = archive[i]
		if data == {}:
			continue

		var item_type = data["item_type"]
		var details = data["item_detail"]
		var count = data["count"]

		if details.size() == 0:
			continue

		var first_detail = details[0]
		var texture = load(first_detail["texture_path"])

		var slot = slots[i]
		slot.set_item(texture, item_type, first_detail, count)


func update_inventory_ui():
	refresh()
