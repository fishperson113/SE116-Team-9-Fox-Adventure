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
func export_texture() -> ImageTexture:
	var vp := SubViewport.new()
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	vp.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	vp.transparent_bg = true
	vp.size = Vector2(512, 512)

	add_child(vp)

	# Duplicate toàn bộ WeaponAssembler (UI containers included)
	var clone := self.duplicate()
	vp.add_child(clone)

	# Center clone bên trong viewport
	clone.position = vp.size / 2

	# Chờ frame để viewport render
	await RenderingServer.frame_post_draw

	var img: Image = vp.get_texture().get_image()
	var tex := ImageTexture.create_from_image(img)

	vp.queue_free()
	return tex


# ---------------------------------------------------------
#  GET CONTAINER FOR PART TYPE
# ---------------------------------------------------------
func get_container_for_type(p_type: String) -> Node:
	var name = p_type.capitalize() + "Container"
	var path_to_node = name
	if has_node(path_to_node):
		return get_node(path_to_node)
	return null

func export_to_image() -> Image:
	# Chờ render xong
	await RenderingServer.frame_post_draw
	
	# Lấy ảnh từ viewport hiện tại
	var viewport = get_viewport()
	var full_img = viewport.get_texture().get_image()
	
	# Tính bounds
	var bounds = _get_weapon_bounds()
	
	# Crop theo bounds + padding
	var padding = 20
	var crop_rect = Rect2(
		bounds.position.x - padding,
		bounds.position.y - padding,
		bounds.size.x + padding * 2,
		bounds.size.y + padding * 2
	)
	
	return full_img.get_region(crop_rect)

func _get_weapon_bounds() -> Rect2:
	var bounds: Rect2
	var first = true
	for p_data in assembled_parts:
		var sprite = p_data["sprite"]
		if first:
			bounds = sprite.get_global_rect()
			first = false
		else:
			bounds = bounds.merge(sprite.get_global_rect())
	return bounds
	
func export_to_resource() -> WeaponData:
	# 1. Tạo hình ảnh (đã crop)
	var final_image = await export_to_image()
	
	# 2. Tạo đường dẫn và lưu file .png
	# Đảm bảo thư mục tồn tại
	DirAccess.make_dir_recursive_absolute("user://generated_weapons/")
	
	# Tạo tên file unique (dùng timestamp)
	var timestamp = Time.get_unix_time_from_system()
	var icon_save_path = "user://generated_weapons/weapon_{ts}.png".format({"ts": timestamp})
	
	var err = final_image.save_png(icon_save_path)
	if err != OK:
		push_error("Failed to save weapon icon: " + icon_save_path)
		return null

	# 3. Tạo "công thức" (blueprint)
	var parts_data: Array[Dictionary] = []
	for p in assembled_parts:
		parts_data.append({
			"id": p["id"],
			"quality": p["quality"],
			"material": p["material"]
		})

	# 4. Tính Stats
	var final_stats = get_stats()

	# 5. Tạo Resource
	var weapon_res := WeaponData.new()
	weapon_res.icon_path = icon_save_path
	weapon_res.parts_list = parts_data
	weapon_res.stats = final_stats
	weapon_res.display_name = "My Awesome Sword" # (Nên cho người dùng đặt tên)

	# 6. Lưu file .tres
	var resource_save_path = "user://generated_weapons/weapon_{ts}.tres".format({"ts": timestamp})
	err = ResourceSaver.save(weapon_res, resource_save_path)
	
	if err != OK:
		push_error("Failed to save weapon resource: " + resource_save_path)
		return null

	print("Weapon exported successfully to: " + resource_save_path)
	return weapon_res
