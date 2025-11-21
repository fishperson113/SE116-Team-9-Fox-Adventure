extends Control
class_name WeaponAssembler

@export var database: WeaponDatabase
@export var parts_folder: String = "res://assets/sprites/weapon_parts/"

var part_map := {}
var material_map := {}
var assembled_parts: Array = []
var texture_cache := {}    # vẫn giữ nếu bạn cần export png nhanh

func _ready() -> void:
	_build_lookup_tables()


# ---------------------------------------------------------
#  BUILD LOOKUP TABLES
# ---------------------------------------------------------
func _build_lookup_tables():
	part_map.clear()
	material_map.clear()

	for p in database.parts:
		part_map[p.id] = p

	for m in database.materials:
		material_map[m.id] = m


# ---------------------------------------------------------
#  ADD PART (Resource-based)
# ---------------------------------------------------------
func add_part(part_id: String, material_id: String) -> Dictionary:
	if not part_map.has(part_id):
		push_error("Unknown part_id: " + part_id)
		return {}

	var part: WeaponPartData = part_map[part_id]
	var material: WeaponMaterialData = material_map.get(material_id, null)

	var container: Control = get_container_for_type(part.type)
	if container == null:
		push_error("Missing container: " + str(part.type))
		return {}

	# Create TextureRect child
	var sprite := TextureRect.new()
	sprite.texture = part.sprite
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	sprite.custom_minimum_size = part.sprite.get_size()

	# Center via anchors
	sprite.set_anchors_preset(Control.PRESET_CENTER)
	sprite.position = Vector2.ZERO

	if part.uses_material and material:
		sprite.modulate = material.color
	else:
		sprite.modulate = Color.WHITE

	container.add_child(sprite)

	var data := {
		"id": part_id,
		"part": part,
		"material": material,
		"sprite": sprite,
		"type": part.type,
		"container": container,
	}

	assembled_parts.append(data)
	return data


# ---------------------------------------------------------
#  EXPORT PNG (unchanged, only switching to Resource sprite)
# ---------------------------------------------------------
func export_png() -> String:
	var root := Node2D.new()
	var current_y := 0.0

	for p in assembled_parts:
		var part:WeaponPartData = p["part"]

		var sp := Sprite2D.new()
		sp.texture = part.sprite
		sp.centered = true
		sp.rotation_degrees = -90
		sp.position = Vector2(0, -current_y)

		if part.uses_material and p["material"]:
			sp.modulate = p["material"].color

		root.add_child(sp)
		current_y += float(part.height)

	var vp := SubViewport.new()
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	vp.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	vp.transparent_bg = true
	vp.size = Vector2(512, 512)

	get_tree().root.add_child(vp)
	vp.add_child(root)
	root.position = vp.size / 2

	await RenderingServer.frame_post_draw

	var folder := "user://generated_weapons"
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("generated_weapons"):
		dir.make_dir("generated_weapons")

	var timestamp := Time.get_unix_time_from_system()
	var path := "%s/weapon_%s.png" % [folder, timestamp]

	var img := vp.get_texture().get_image()
	img.save_png(path)

	print("Saved crafted weapon to:", path)

	vp.queue_free()

	return path


# ---------------------------------------------------------
#  GET CONTAINER FOR PART TYPE
# ---------------------------------------------------------
func get_container_for_type(p_type: String) -> Node:
	var node_name := p_type.capitalize() + "Container"
	if has_node(node_name):
		return get_node(node_name)
	return null
