extends Control
class_name AllInventory

@export var slot_scene: PackedScene

@onready var grid := $NinePatchRect/GridContainer
@onready var inventory 
var slots: Array[Slot] = []
var is_open := false

func _ready():
	self.visible = false
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$NinePatchRect.mouse_filter = Control.MOUSE_FILTER_STOP
	grid.mouse_filter = Control.MOUSE_FILTER_PASS
	slots = []
	for child in grid.get_children():
		if child is Slot:
			slots.append(child)
	inventory  = GameManager.player.inventory
	for i in range(slots.size()):
		slots[i].parent = inventory
		slots[i].index = i
		
		if not slots[i].request_move.is_connected(_on_slot_request_move):
			slots[i].request_move.connect(_on_slot_request_move)
	
	GameManager.player.inventory.inventory_changed.connect(update_inventory_ui)
	update_inventory_ui()


func _input(event):
	if event.is_action_pressed("open_inventory") && GameManager.player.input_enabled:
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


# ---------------------------------------------------------
# UPDATE UI INVENTORY
# ---------------------------------------------------------
func update_inventory_ui():
	var archive = GameManager.player.inventory.item_archive
	# Reset toàn bộ slot trước
	for slot in slots:
		slot.clear_slot()

	# Gắn item lên slot
	for i in range(min(archive.size(), slots.size())):
		var data = archive[i]

		if data.is_empty():
			continue

		var item_type: String = data["item_type"]
		var detail_list: Array = data["item_detail"]

		if detail_list.is_empty():
			continue

		var icon := load_icon(item_type, detail_list)
		var count := detail_list.size()
		slots[i].parent = inventory
		slots[i].index = i
		if not slots[i].request_move.is_connected(_on_slot_request_move):
			slots[i].request_move.connect(_on_slot_request_move)
		slots[i].set_item(icon, item_type, detail_list, count)

func _on_slot_request_move(parent_node, from_index, to_index):
	parent_node.move(from_index, to_index)

# ---------------------------------------------------------
# LOAD ICON
# ---------------------------------------------------------
func load_icon(item_type: String, item_detail_list: Array) -> Texture2D:
	return _get_weapon_icon(item_detail_list)


func _get_weapon_icon(item_detail_list: Array) -> Texture2D:
	var weapon_data = _load_weapon_data(item_detail_list)
	if not weapon_data:
		return null

	return _load_texture_from_disk(weapon_data.png_path)


func _load_weapon_data(item_detail_list: Array) -> WeaponData:
	if item_detail_list.is_empty() or not (item_detail_list[0] is String):
		return null
	
	var weapon_path = item_detail_list[0]

	if not ResourceLoader.exists(weapon_path):
		return null

	return load(weapon_path) as WeaponData


func _load_texture_from_disk(path: String) -> Texture2D:
	if path == "" or not FileAccess.file_exists(path):
		return null

	var img = Image.load_from_file(path)
	if img:
		return ImageTexture.create_from_image(img)

	return null

func _handle_transfer(src_parent, from_index, to_parent, to_index):
	var src_data = src_parent.item_archive[from_index]

	var item_type = src_data["item_type"]
	var item_detail = src_data["item_detail"].duplicate(true)

	var dst_data = {}
	if to_index < to_parent.item_archive.size():
		dst_data = to_parent.item_archive[to_index]

	if to_index < to_parent.item_archive.size():
		to_parent.item_archive[to_index] = {
			"item_type": item_type,
			"item_detail": item_detail,
		}
	else:
		to_parent.item_archive.append({
			"item_type": item_type,
			"item_detail": item_detail,
		})

	if dst_data.is_empty():
		src_parent.item_archive.remove_at(from_index)
	else:
		src_parent.item_archive[from_index] = dst_data

	src_parent.emit_signal("inventory_changed")
	to_parent.emit_signal("inventory_changed")
