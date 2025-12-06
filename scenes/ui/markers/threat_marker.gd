class_name ThreatMarker
extends Node2D

@export var screen_margin: Vector2 = Vector2(4.0, 4.0)
@export var smoothing_speed: float = 8.0

var camera: Camera2D
var target: Node2D

func _ready() -> void:
	camera = get_viewport().get_camera_2d()

func set_target(body: Node2D) -> void:
	target = body

func _process(delta: float) -> void:
	# No target → auto-clean.
	if not is_instance_valid(target):
		queue_free()
		print("ThreatMarker freed: target invalid")
		return

	# Camera might not be ready on first frame.
	if not camera:
		camera = get_viewport().get_camera_2d()
		return

	update_marker(delta)


func update_marker(delta: float) -> void:
	var viewport_size := get_viewport_size_adjusted()
	var offset_from_camera := target.global_position - camera.global_position

	# Ratio determines if marker is off-screen
	var max_bounds := viewport_size * 0.5 - screen_margin
	var ratio := compute_axis_ratio(offset_from_camera, max_bounds)

	if ratio < 1.0:
		hide()
		return

	show()
	apply_marker_transform(delta, offset_from_camera, ratio)

func apply_marker_transform(delta: float, offset: Vector2, ratio: float) -> void:
	var target_pos := offset / ratio + camera.global_position
	var target_rot := offset.angle() - PI * 0.5
	var target_scale := Vector2.ONE / ratio
	var target_alpha := 1.0 / ratio

	global_position = target_pos
	rotation = target_rot
	scale = lerp(scale, target_scale, delta * smoothing_speed)
	modulate.a = lerp(modulate.a, target_alpha, delta * smoothing_speed)

func get_viewport_size_adjusted() -> Vector2:
	# Correct for camera zoom
	return get_viewport().get_visible_rect().size / camera.zoom


func compute_axis_ratio(vec_a: Vector2, vec_b: Vector2) -> float:
	if vec_b.x == 0.0 or vec_b.y == 0.0:
		push_warning("compute_axis_ratio(): vec_b contains zero component.")
		return 0.0

	var ratio_x := absf(vec_a.x) / absf(vec_b.x)
	var ratio_y := absf(vec_a.y) / absf(vec_b.y)
	return maxf(ratio_x, ratio_y)
