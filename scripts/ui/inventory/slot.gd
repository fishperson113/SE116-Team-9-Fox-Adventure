extends Panel
class_name Slot

@onready var highlighted_icon: CompressedTexture2D = preload("res://assets/ui/inventory/inventory_icon_highlighted.png")
@onready var non_highlighted_icon: CompressedTexture2D = preload("res://assets/ui/inventory/inventory_icon_not_highlighted.png")

@onready var background: TextureRect = $Background
@onready var icon: TextureRect = $Icon
@onready var qty: Label = $Number
@onready var inventory = GameManager.player.inventory
@onready var item_storer = GameManager.player.item_storer
signal request_move(parent_node, from_index, to_index)

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
	preview.z_index = 100
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.size = icon.size
	set_drag_preview(preview)
	return data

func _can_drop_data(_at_position, data):
	return data is Dictionary and data.has("item_type")

func _drop_data(_at_position, data):
	var src: Slot = data["source_slot"]

	if src == self:
		return
	
	var cur_tex = icon.texture
	var cur_type = item_type
	var cur_detail = item_detail
	var cur_count = quantity
	
	if parent == src.parent:
		print(parent)
		emit_signal("request_move", parent, src.index, index)
		return
		
	exchange(src.parent, src.index, parent, index)
			
func exchange(src_parent, src_index, dst_parent, dst_index):
	# Lấy data từ slot nguồn
	var src_data
	if src_parent == inventory:
		if src_index >= inventory.item_archive.size():
			print("ERROR: src_index out of range")
			return
		src_data = inventory.item_archive[src_index]
	else:
		src_data = item_storer.item_archive[src_index]
	
	print("Source data: ", src_data)
	
	# Lấy data từ slot đích
	var dst_data = null
	var dst_is_empty = true
	
	if dst_parent == inventory:
		if dst_index < inventory.item_archive.size():
			dst_data = inventory.item_archive[dst_index]
			dst_is_empty = (dst_data == null or (dst_data is Dictionary and dst_data.is_empty()))
		else:
			# Slot nằm ngoài range → coi như trống
			dst_is_empty = true
	else:
		dst_data = item_storer.item_archive[dst_index]
		dst_is_empty = (dst_data == null or (dst_data is Dictionary and dst_data.is_empty()))
	
	print("Dest data: ", dst_data)
	print("Dest is empty: ", dst_is_empty)
	
	# ===== Inventory ↔ ItemStorer =====
	if src_parent == inventory and dst_parent == item_storer:
		print("→ Inventory to ItemStorer")
		
		# Ghi vào slot đích
		item_storer.item_archive[dst_index] = src_data
		
		# Xử lý slot nguồn
		if dst_is_empty:
			print("  Removing from inventory[", src_index, "]")
			inventory.item_archive.remove_at(src_index)
		else:
			print("  Swapping inventory[", src_index, "] = ", dst_data)
			inventory.item_archive[src_index] = dst_data
		
		inventory.inventory_changed.emit()
		item_storer.slot_changed.emit(dst_index)
		
		if dst_index == item_storer.item_slot:
			item_storer._equip_current_slot_weapon()
	
	# ===== ItemStorer → Inventory =====
	elif src_parent == item_storer and dst_parent == inventory:
		print("→ ItemStorer to Inventory")
		
		if dst_is_empty:
			print("  Appending to inventory")
			# Slot đích trống → append vào cuối
			inventory.item_archive.append(src_data)
			# Xóa slot nguồn
			item_storer.item_archive[src_index] = {}
		else:
			print("  Swapping with inventory[", dst_index, "]")
			# Slot đích có item → swap
			inventory.item_archive[dst_index] = src_data
			item_storer.item_archive[src_index] = dst_data
		
		inventory.inventory_changed.emit()
		item_storer.slot_changed.emit(src_index)
		
		if src_index == item_storer.item_slot:
			item_storer._equip_current_slot_weapon()
	GameManager.player.item_storer.save_slots()
	GameManager.player.inventory.save_inventory()
	
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
	# 1. Nếu không có item thì không hiện gì cả
	if item_type == "":
		tooltip_text = ""
		return

	# Tên mặc định là loại item (ví dụ: Weapon Blade)
	var title_text = item_type.replace("_", " ").capitalize()
	var stats_text = ""

	# 2. Kiểm tra nếu là Vũ khí
	if item_type.begins_with("weapon_") and item_detail is Array and item_detail.size() > 0:
		var weapon_path = item_detail[0]
		
		# Load Resource an toàn
		if weapon_path is String and ResourceLoader.exists(weapon_path):
			var weapon: WeaponData = load(weapon_path)
			
			if weapon:
				# --- PHẦN TÊN ---
				# Nếu vũ khí đã được đặt tên, dùng tên đó làm tiêu đề chính
				if weapon.weapon_name != "":
					title_text = weapon.weapon_name
				
				# Thêm dòng phụ để biết đây là loại vũ khí gì (Blade/Crossguard/...)
				stats_text += "\n[%s]" % item_type.replace("weapon_", "").capitalize()
				
				# --- PHẦN CHỈ SỐ ---
				
				# Damage
				var dmg = weapon.get_damage()
				if dmg > 0:
					stats_text += "\n Damage: %d" % dmg
				
				# Durability
				var dur = weapon.get_durability()
				# Chỉ hiện nếu độ bền > 0 (tức là không phải vô hạn hoặc đã vỡ)
				if dur > 0:
					stats_text += "\n Durability: %.1f" % dur
				elif dur == 0:
					stats_text += "\n Durability: BROKEN"
				
				# Health Bonus
				var hp = weapon.get_max_health()
				if hp > 0:
					stats_text += "\n Health: +%d" % hp
					
				# Knockback
				var kb = weapon.get_knock_back_force()
				if kb > 0:
					stats_text += "\n Knockback: %.1f" % kb
				
				# Special Skill
				var skill = weapon.get_special_skill()
				if skill != "":
					stats_text += "\n Skill: %s" % skill.replace("_", " ").capitalize()

	tooltip_text = "%s%s" % [title_text, stats_text]
