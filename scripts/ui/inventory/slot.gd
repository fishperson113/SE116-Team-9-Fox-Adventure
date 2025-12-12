extends Panel
class_name Slot

@onready var highlighted_icon: CompressedTexture2D = preload("res://assets/ui/inventory/inventory_icon_highlighted.png")
@onready var non_highlighted_icon: CompressedTexture2D = preload("res://assets/ui/inventory/inventory_icon_not_highlighted.png")

@onready var background: TextureRect = $Background
@onready var icon: TextureRect = $Icon
@onready var qty: Label = $Number
@onready var inventory = GameManager.player.inventory
@onready var item_storer = GameManager.player.item_storer

signal request_move(src_parent, from_index, dst_parent, to_index)

var item_type: String = ""
var item_detail = null
var quantity: int = 0
var parent
var index: int

func set_item(texture: Texture2D, type: String, detail, amount: int = 1):
	icon.texture = texture
	item_type = type
	item_detail = detail
	quantity = amount

	qty.text = str(quantity)
	qty.visible = quantity > 1
	_update_tooltip()

func clear_slot():
	icon.texture = null
	qty.visible = false

	item_type = ""
	item_detail = null
	quantity = 0
	tooltip_text = ""

# --- DRAG LOGIC ---
func _get_drag_data(_at_position):
	if icon.texture == null:
		return null

	var data := {
		"texture": icon.texture,
		"item_type": item_type,
		"item_detail": item_detail,
		"count": quantity,
		"source_slot": self
	}

	var preview := TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.size = icon.size
	
	# Làm mờ preview một chút cho đẹp
	preview.modulate.a = 0.8
	
	set_drag_preview(preview)
	return data

func _can_drop_data(_at_position, data):
	return data is Dictionary and data.has("item_type")

func _drop_data(_at_position, data):
	var src: Slot = data["source_slot"]

	if src == self:
		return
	
	if parent == src.parent:
		emit_signal("request_move", parent, src.index, parent, index)
	else:
		exchange(src.parent, src.index, parent, index)

# --- DATA LOGIC ---
func exchange(src_parent, src_index, dst_parent, dst_index):
	var src_data
	if src_parent == inventory:
		src_data = inventory.item_archive[src_index]
	else:
		src_data = item_storer.items_archive[src_index]
		
	var dst_data
	if dst_parent == inventory:
		dst_data = inventory.item_archive[dst_index]
	else:
		dst_data = item_storer.items_archive[dst_index]

	# Swap Data
	if src_parent == inventory and dst_parent == item_storer:
		inventory.item_archive[src_index] = dst_data
		item_storer.items_archive[dst_index] = src_data
	elif src_parent == item_storer and dst_parent == inventory:
		item_storer.items_archive[src_index] = dst_data
		inventory.item_archive[dst_index] = src_data
	
	# Emit Signal để UI (InvUI) vẽ lại
	inventory.inventory_changed.emit()
	
	# Nếu dính đến ItemStorer (Hotbar), cần báo slot changed
	if src_parent == item_storer:
		item_storer.slot_changed.emit(src_index)
	if dst_parent == item_storer:
		item_storer.slot_changed.emit(dst_index)

# --- VISUAL HELPERS ---
func highlight(active: bool):
	# (Code highlight giữ nguyên như của bạn)
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	
	if active:
		style.border_color = Color.WHITE
		style.border_width_left = 3
		style.border_width_right = 3
		style.border_width_top = 3
		style.border_width_bottom = 3
		style.shadow_color = Color.WHITE
		style.shadow_size = 4
		background.texture = highlighted_icon
	else:
		style.border_width_left = 0
		style.border_width_right = 0
		style.border_width_top = 0
		style.border_width_bottom = 0
		style.shadow_size = 0
		background.texture = non_highlighted_icon

	add_theme_stylebox_override("panel", style)

func _update_tooltip():
	if item_type == "":
		tooltip_text = ""
		return

	var text_content = item_type.replace("_", " ").capitalize()

	if item_type.begins_with("weapon_") and item_detail is Array and item_detail.size() > 0:
		var weapon_path = item_detail[0]
		
		if weapon_path is String and ResourceLoader.exists(weapon_path):
			var weapon: WeaponData = load(weapon_path)
			
			if weapon:
				text_content += "\n━━━━━━━━━━━━━"
				
				var dmg = weapon.get_damage()
				if dmg > 0:
					text_content += "\n⚔ Damage: %d" % dmg
				
				# THÊM HIỂN THỊ DURABILITY TRONG KHO
				var dur = weapon.get_durability()
				if dur > 0:
					text_content += "\n🛡️ Durability: %.1f" % dur
				
				var hp = weapon.get_max_health()
				if hp > 0:
					text_content += "\n♥ Health: +%d" % hp
					
				var spd = weapon.get_attack_speed()
				text_content += "\n⚡ Speed: %.1f" % spd
				
				var skill = weapon.get_special_skill()
				if skill != "":
					text_content += "\n★ Skill: %s" % skill.capitalize()

	tooltip_text = text_content
