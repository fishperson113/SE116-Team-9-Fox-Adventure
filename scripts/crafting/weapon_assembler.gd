extends Control
class_name WeaponAssembler

# CONFIG + CACHE
var config: Dictionary = {}
var parts: Dictionary = {}
var materials: Dictionary = {}
var qualities: Dictionary = {}
var assembled_parts: Array[Dictionary] = []
var texture_cache: Dictionary = {}

@export var config_path: String = "res://data/parts_config.json"
@export var parts_folder: String = "res://assets/sprites/weapon_parts/"


func _ready() -> void:
	load_config()

# ---------------------------------------------------------
#  LOAD JSON CONFIG
# ---------------------------------------------------------
func load_config() -> void:
	var file := FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("Cannot load JSON at: " + config_path)
		return

	var json_text: String = file.get_as_text()
	var result = JSON.parse_string(json_text)

	if typeof(result) != TYPE_DICTIONARY:
		push_error("Invalid JSON structure.")
		return

	config = result
	parts = config.get("parts", {})
	materials = config.get("materials", {})
	qualities = config.get("qualities", {})



# ---------------------------------------------------------
#  ADD PART — WITH ANCHOR SUPPORT (FIX CENTER ALIGN)
# ---------------------------------------------------------
func add_part(part_id: String, quality: String, material: String) -> Dictionary:
	if not parts.has(part_id):
		push_error("Unknown part_id: " + part_id)
		return {}

	var cfg: Dictionary = parts[part_id]

	var container: Control = get_container_for_type(cfg["type"])
	if container == null:
		push_error("Missing container: " + cfg["type"])
		return {}

	# Create TextureRect child
	var sprite := TextureRect.new()
	var tex = load_texture_cached(parts_folder + part_id + ".png")
	sprite.texture = tex
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.custom_minimum_size = tex.get_size()

	# Let CenterContainer do the centering!
	sprite.set_anchors_preset(Control.PRESET_CENTER)
	sprite.position = Vector2.ZERO   # <-- PHẢI là 0,0 để centerContainer canh giữa

	# Apply material
	if cfg.get("uses_material", false):
		sprite.modulate = get_material_color(material)
	else:
		sprite.modulate = Color.WHITE

	container.add_child(sprite)

	var data := {
		"id": part_id,
		"quality": quality,
		"material": material,
		"config": cfg,
		"sprite": sprite,
		"type": cfg["type"],
		"container":container
	}

	assembled_parts.append(data)
	return data

# ---------------------------------------------------------
#  TEXTURE CACHE
# ---------------------------------------------------------
func load_texture_cached(path: String) -> Texture2D:
	if texture_cache.has(path):
		return texture_cache[path]

	var tex = load(path)
	if tex is Texture2D:
		texture_cache[path] = tex
		return tex

	return null

# ---------------------------------------------------------
#  MATERIAL COLOR (RGB → Color)
# ---------------------------------------------------------
func get_material_color(material: String) -> Color:
	if not materials.has(material):
		return Color.WHITE

	var rgb = materials[material].get("color", [1.0, 1.0, 1.0])
	return Color(float(rgb[0]), float(rgb[1]), float(rgb[2]))



# ---------------------------------------------------------
#  STATS
# ---------------------------------------------------------
func get_stats() -> Dictionary:
	var out := {}

	for p in assembled_parts:
		var base_stats: Dictionary = p["config"].get("stats", {})
		var quality = p.get("quality", "perfect")
		var mult: float = qualities.get(quality, {}).get("multiplier", 1.0)

		for stat_name in base_stats.keys():
			out[stat_name] = out.get(stat_name, 0.0) + float(base_stats[stat_name]) * mult

	return out

# ---------------------------------------------------------
#  EXPORT TO TEXTURE
# ---------------------------------------------------------
func export_png() -> String:
	# -------------------------
	# 1) Dựng weapon bằng Node2D
	# -------------------------
	var root := Node2D.new()
	var current_y := 0.0

	for p in assembled_parts:
		var tex: Texture2D = load_texture_cached(parts_folder + p["id"] + ".png")

		var sp := Sprite2D.new()
		sp.texture = tex
		sp.centered = true
		sp.rotation_degrees = -90
		sp.position = Vector2(0, -current_y)

		if p["config"].get("uses_material", false):
			sp.modulate = get_material_color(p["material"])

		root.add_child(sp)

		current_y += float(p["config"].get("height", 0))

	# -------------------------
	# 2) SubViewport render PNG
	# -------------------------
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

	# -------------------------
	# 3) Tạo thư mục nếu chưa có
	# -------------------------
	var folder := "user://generated_weapons"
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("generated_weapons"):
		dir.make_dir("generated_weapons")

	# -------------------------
	# 4) Lưu PNG theo timestamp
	# -------------------------
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
	var name = p_type.capitalize() + "Container"
	var path_to_node = name
	if has_node(path_to_node):
		return get_node(path_to_node)
	return null
