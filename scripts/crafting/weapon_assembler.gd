extends Node2D
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
#  ADD PART
# ---------------------------------------------------------
func add_part(part_id: String, quality: String, material: String) -> Dictionary:
	var cfg = parts[part_id]
	var container := get_container_for_type(cfg["type"])

	var sprite := Sprite2D.new()
	sprite.centered = true
	sprite.texture = load_texture_cached(parts_folder + part_id + ".png")
	if cfg.get("uses_material", false):
		sprite.modulate = get_material_color(material)
	else:
		sprite.modulate = Color.WHITE

	# stacking
	sprite.position = Vector2(0, -calculate_y_position())

	container.add_child(sprite)

	var data := {
		"id": part_id,
		"quality": quality,
		"material": material,
		"config": cfg,
		"sprite": sprite,
		"type": cfg["type"]
	}

	assembled_parts.append(data)
	return data




# ---------------------------------------------------------
#  HEIGHT STACKING
# ---------------------------------------------------------
func calculate_y_position() -> float:
	var total_height: float = 0.0

	for p: Dictionary in assembled_parts:
		var h: float = float(p["config"].get("height", 0))
		total_height += h

	return total_height


# ---------------------------------------------------------
#  TEXTURE CACHE
# ---------------------------------------------------------
func load_texture_cached(path: String) -> Texture2D:
	if texture_cache.has(path):
		return texture_cache[path]

	var tex := load(path)
	if tex is Texture2D:
		texture_cache[path] = tex as Texture2D
		return tex

	return null


# ---------------------------------------------------------
#  MATERIAL COLOR (RGB array → Color)
# ---------------------------------------------------------
func get_material_color(material: String) -> Color:
	if not materials.has(material):
		return Color.WHITE

	var rgb_val = materials[material].get("color", [1.0, 1.0, 1.0])
	var rgb: Array = rgb_val

	return Color(
		float(rgb[0]),
		float(rgb[1]),
		float(rgb[2])
	)


# ---------------------------------------------------------
#  FINAL STATS CALCULATION
# ---------------------------------------------------------
func get_stats() -> Dictionary:
	var final_stats: Dictionary = {}

	for p: Dictionary in assembled_parts:
		var base_stats: Dictionary = p["config"].get("stats", {})
		var q: String = p.get("quality", "perfect")
		var mult: float = qualities.get(q, {}).get("multiplier", 1.0)

		for stat_name: String in base_stats.keys():
			var value: float = float(base_stats[stat_name]) * mult
			final_stats[stat_name] = final_stats.get(stat_name, 0.0) + value

	return final_stats


# ---------------------------------------------------------
#  EXPORT WEAPON AS TEXTURE (SubViewport)
# ---------------------------------------------------------
func export_texture() -> ImageTexture:
	var viewport := SubViewport.new()
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.transparent_bg = true
	viewport.size = Vector2(512, 512)

	add_child(viewport)

	var clone := duplicate(0)
	viewport.add_child(clone)

	await RenderingServer.frame_post_draw

	var img: Image = viewport.get_texture().get_image()
	var tex := ImageTexture.create_from_image(img)

	viewport.queue_free()

	return tex
	
func get_container_for_type(p_type: String) -> Node:
	var name = p_type.capitalize() + "Container"
	if has_node(name):
		return get_node(name)
	return null
