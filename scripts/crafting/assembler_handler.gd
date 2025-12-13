extends Control
class_name AssemblerHandler

signal assemble_done(export_path)

@export var assembler: WeaponAssembler
@export var assemble_area: Control # Đây là vùng nhận Drop

@onready var list_container := $ScrollContainer/VBoxContainer
@onready var scroll_view := $ScrollContainer
@onready var naming_container := $"../AssembleArea/WeaponAssembler/NamingContainer"
@onready var name_input := $"../AssembleArea/WeaponAssembler/NamingContainer/NameLineEdit"
@onready var confirm_btn := $"../AssembleArea/WeaponAssembler/NamingContainer/ConfirmButton"
@onready var instructLabel:=$"../AssembleArea/WeaponAssembler/Label"
var current_stage: int = 1
const MAX_STAGE := 4

const STAGE_TYPES := {
	1: "crossguard",
	2: "grip",
	3: "pommel"
}

func _ready():
	if assembler == null:
		await get_tree().process_frame
	
	# SETUP CHO VÙNG NHẬN DROP (Assemble Area)
	# Logic: Khi chuột kéo vật phẩm vào vùng này, các hàm này sẽ chạy
	assemble_area.set_drag_forwarding(
		func(_pos): return null, # Area không cho kéo đi
		_can_drop_on_area,       # Kiểm tra xem thả được không
		_drop_on_area            # Xử lý khi thả
	)
	gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed:
			print("Collection Area đã nhận được Click! -> Mouse path thông thoáng")
	)
	confirm_btn.pressed.connect(_on_confirm_name_pressed)
	naming_container.visible = false # Ẩn lúc đầu
	instructLabel.visible=true
	#populate_parts()

# Hàm _process cũ đã bị xóa vì Control tự xử lý vị trí chuột

func populate_parts():
	for c in list_container.get_children():
		c.queue_free()
	if current_stage == MAX_STAGE:
		_show_naming_stage()
		return
	var required_type = STAGE_TYPES.get(current_stage, "")

	for part_id in assembler.part_map.keys():
		var part: WeaponPartData = assembler.part_map[part_id]

		if part.type != required_type:
			continue
			
		var tex := part.sprite
		var btn := Button.new()
		
		# --- Setup Button Visual ---
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 120)
		btn.focus_mode = Control.FOCUS_NONE
		
		# --- SETUP TOOLTIP (ĐÃ CẬP NHẬT) ---
		var name_str = part.display_name if part.display_name != "" else part.id.capitalize()
		
		# Tạo dòng hiển thị chỉ số dựa trên loại part
		var stat_info := ""
		match part.type:
			"blade":
				stat_info = "Damage: +%d" % part.damage
			"crossguard":
				stat_info = "Health Bonus: +%d" % part.max_health
			"grip":
				# Hiển thị 2 số thập phân cho tốc độ đánh
				stat_info = "Knock Back: +%.2f" % part.knock_back_force
			"pommel":
				stat_info = "Skill: %s" % part.special_skill.capitalize()

		# Gộp thông tin lại: Tên -> Loại -> Chỉ số
		var info_text = "%s\n[%s]\n%s" % [name_str, part.type.capitalize(), stat_info]
		btn.tooltip_text = info_text
		# ----------------------------------------------

		var icon := TextureRect.new()
		icon.texture = tex
		icon.custom_minimum_size = Vector2(96, 96)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.anchor_left = 0.5
		icon.anchor_right = 0.5
		icon.offset_left = -48
		icon.offset_top = 12
		icon.mouse_filter = Control.MOUSE_FILTER_PASS
		btn.add_child(icon)

		# --- SETUP DRAG CHO BUTTON ---
		btn.set_drag_forwarding(
			func(_pos): return _get_part_drag_data(part_id, tex, icon.size),
			func(_pos, _data): return false, 
			func(_pos, _data): pass
		)

		list_container.add_child(btn)

func _show_naming_stage():
	print("Entering Naming Stage")
	scroll_view.visible = false 
	naming_container.visible = true 
	name_input.text = "" 
	name_input.placeholder_text = "Enter weapon name..."
	name_input.grab_focus() 
	
func _on_confirm_name_pressed():
	var final_name = name_input.text.strip_edges()
	
	if final_name == "":
		final_name = "Unnamed Weapon" # Tên mặc định nếu để trống
	naming_container.visible = false
	# Gọi hàm finish
	_finish_assembling(final_name)
	
func _finish_assembling(weapon_name: String):
	# 1. Export ảnh
	var png_path := await assembler.export_png()
	
	# 2. Tạo data
	var weapon_data := assembler.export_weapon_data(png_path)
	
	# 3. SET TÊN VŨ KHÍ VÀO DATA
	weapon_data.weapon_name = weapon_name
	
	# 4. Lưu file .tres
	var tres_path := assembler.save_weapon_tres(weapon_data)
	
	print("Completed! Name: %s, Path: %s" % [weapon_name, tres_path])
	emit_signal("assemble_done", tres_path)
	
# --- PHẦN LOGIC DRAG (CHUẨN CONTROL) ---

func _get_part_drag_data(part_id: String, tex: Texture2D, size: Vector2):
	# 1. Tạo dữ liệu để truyền đi
	var data = {
		"part_id": part_id,
		"item_type": assembler.part_map[part_id].type,
		"texture": tex
	}

	# 2. Tạo Preview (Hình ảnh đi theo chuột)
	var preview = TextureRect.new()
	preview.texture = tex
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = size
	
	preview.pivot_offset = size / 2
	preview.rotation_degrees = -90
	
	preview.modulate.a = 0.8
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Hàm này của Godot tự động làm preview đi theo chuột chuẩn xác
	set_drag_preview(preview)
	
	return data

# --- PHẦN LOGIC DROP (CHUẨN CONTROL) ---

func _can_drop_on_area(_at_position, data) -> bool:

	print("Mouse is over area! Checking data...")
	if not data is Dictionary or not data.has("part_id"):
		return false
		
	# Check đúng stage type
	var required_type = STAGE_TYPES.get(current_stage, "")
	if data["item_type"] != required_type:
		return false
	if current_stage == MAX_STAGE:
		return false
	return true

func _drop_on_area(_at_position, data):
	# Khi thả chuột thành công
	var part_id = data["part_id"]
	
	# Thêm part vào assembler
	var part_data = assembler.add_part(part_id, "copper")
	var container: Control = part_data["container"]

	# Animate và chuyển stage (Logic giữ nguyên)
	var tw = animate_part_drop(container)
	await advance_stage(tw)

# --- CÁC HÀM ANIMATION & LOGIC CŨ (GIỮ NGUYÊN) ---

func animate_part_drop(container: Control) -> Tween:
	var tw := create_tween()
	var final_local := container.position
	
	container.visible = false
	container.position = final_local + Vector2(0, -150)
	container.visible = true

	tw.tween_property(container, "position", final_local, 0.25) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)
	return tw

func advance_stage(tw: Tween) -> void:
	current_stage += 1
	
	await tw.finished
	
	populate_parts()

func reset_handler():
	current_stage = 1
	naming_container.visible = false # Ẩn lúc đầu
	instructLabel.visible=true
	scroll_view.visible = true

	#populate_parts()
	clear_current_parts()
	
func clear_current_parts():
	for c in list_container.get_children():
		c.queue_free()
