extends Control
class_name AssemblerHandler

signal assemble_done(export_path)

@export var assembler: WeaponAssembler
@export var assemble_area: Control

@onready var list_container := $ScrollContainer/VBoxContainer

var dragging_part: String = ""
var dragging_icon: Node2D = null

var current_stage: int = 1
const MAX_STAGE := 3

const STAGE_TYPES := {
	1: "crossguard",
	2: "grip",
	3: "pommel"
}


func _ready():
	# Chờ 1 frame để đảm bảo assembler load config
	if assembler == null:
		await get_tree().process_frame
	populate_parts()


func _process(delta):
	if dragging_icon:
		dragging_icon.global_position = get_global_mouse_position()


func populate_parts():
	for c in list_container.get_children():
		c.queue_free()

	var required_type = STAGE_TYPES.get(current_stage, "")

	for part_id in assembler.part_map.keys():
		var part:WeaponPartData = assembler.part_map[part_id]

		if part.type != required_type:
			continue
			
		var tex := part.sprite

		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 120)
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_constant_override("content_margin_left", 0) 
		btn.add_theme_constant_override("content_margin_right", 0)


		var icon := TextureRect.new()
		icon.texture = tex
		icon.custom_minimum_size = Vector2(96, 96)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.anchor_left = 0.5
		icon.anchor_right = 0.5 
		icon.offset_left = -48 
		icon.offset_top = 12
		btn.add_child(icon)

		btn.connect("gui_input", func(event):
			_on_part_button_input(part_id, tex, event)
		)

		list_container.add_child(btn)


func _on_part_button_input(part_id: String, tex: Texture2D, event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragging_part = part_id
		_start_drag_icon(tex)

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragging_icon:
			_drop_part()


func _start_drag_icon(tex: Texture2D):
	# Wrapper xoay được
	dragging_icon = Node2D.new()
	dragging_icon.z_index = 999

	var tex_node := Sprite2D.new()
	tex_node.texture = tex
	tex_node.centered = true
	tex_node.scale = Vector2(1, 1)  # giống ~96px
	tex_node.rotation_degrees = -90

	dragging_icon.add_child(tex_node)
	get_tree().root.add_child(dragging_icon)

	# đặt vị trí đúng vào con trỏ
	dragging_icon.global_position = get_global_mouse_position()


func _drop_part():
	var mouse_pos = get_global_mouse_position()

	# 1) Kiểm tra hợp lệ
	if not can_drop_part(mouse_pos):
		_reset_drag()
		return

	# 2) Thêm part vào assembler
	var part_data = assembler.add_part(dragging_part, "copper")
	var container: Control = part_data["container"]

	# 3) Animate rơi
	var tw = animate_part_drop(container)

	# 4) Chuyển stage
	await advance_stage(tw)

	# 5) Cleanup drag icon
	_reset_drag()

func can_drop_part(mouse_pos: Vector2) -> bool:
	# Phải nằm trong assemble area
	if not assemble_area.get_global_rect().has_point(mouse_pos):
		print("Drop failed → outside assemble area")
		return false

	# Kiểm tra type part có đúng stage
	var required_type = STAGE_TYPES[current_stage]
	var part_type = assembler.part_map[dragging_part].type

	if part_type != required_type:
		print("Drop failed → part type does not match stage")
		return false

	return true
	

func animate_part_drop(container: Control) -> Tween:

	var tw := create_tween()

	# 1. Lưu vị trí local cuối cùng (đúng vị trí snap)
	var final_local := container.position

	# 2. Ẩn rect để tránh nhảy frame
	container.visible = false

	# 3. Dời lên 150px theo local Y
	container.position = final_local + Vector2(0, -150)

	# 4. Bật lại visible
	container.visible = true

	# 5. Tween rơi xuống lại đúng final_local
	tw.tween_property(container, "position", final_local, 0.25) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)
		
	return tw

func advance_stage(tw: Tween) -> void:
	current_stage += 1

	# nếu làm xong toàn bộ
	if current_stage > MAX_STAGE:
		await tw.finished
		# 1) Export PNG
		var png_path := await assembler.export_png()

		# 2) Build WeaponData object
		var weapon_data := assembler.export_weapon_data(png_path)

		# 3) Save to .tres
		var tres_path := assembler.save_weapon_tres(weapon_data)
		emit_signal("assemble_done", tres_path)
		return

	# Ngược lại → cập nhật list parts cho stage mới
	populate_parts()
	
func _reset_drag():
	if dragging_icon:
		dragging_icon.queue_free()

	dragging_icon = null
	dragging_part = ""

func reset_handler():
	dragging_part = ""
	if dragging_icon:
		dragging_icon.queue_free()
	dragging_icon = null

	current_stage = 1
	populate_parts()
