class_name PlayerDetectedMarker
extends BaseMarker

@export var fade_time: float = 0.25

var _trigger: Callable
var _offset: Vector2 = Vector2.ZERO

var _fade_tween: Tween = null
var _bounce_tween: Tween = null
var _bounce_scale : Vector2 = Vector2(1.5, 0.4)
var _bounce_speed : float = 0.35

func _ready() -> void:
	super._ready()

func set_trigger(trigger: Callable, marked_target: Node2D = get_parent()):
	_trigger = trigger
	target = marked_target
	if target:
		_offset = global_position - target.global_position

func update_marker(delta: float) -> void:
	if _trigger and _trigger.call():
		var viewport_size := get_viewport_size_adjusted()
		var offset_from_camera := compute_distance_to_cam()

		var max_bounds := viewport_size * 0.5 - screen_margin
		var ratio := compute_axis_ratio(offset_from_camera, max_bounds)
		ratio = maxf(ratio, 1.0)
		apply_marker_transform(delta, offset_from_camera, ratio)
		play_show_effect()
	else:
		play_hide_effect()
	pass

func compute_distance_to_cam() -> Vector2:
	var _current_pos = global_position
	if target:
		var _transfromed_offset = _offset * target.scale
		_current_pos = target.global_position + _transfromed_offset
	return _current_pos - camera.global_position

func apply_marker_transform(delta: float, offset: Vector2, ratio: float) -> void:
	var target_pos := offset / ratio + camera.global_position

	global_position = target_pos

func play_show_effect():
	show()
	_start_bounce()
	_start_fade()

func play_hide_effect() -> void:
	_end_bounce()
	_end_fade()

func _start_fade() -> void:
	if _fade_tween:
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0, fade_time)

func _end_fade() -> void:
	if _fade_tween:
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, fade_time)
	_fade_tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished() -> void:
	if modulate.a <= 0.01:
		hide()

func _start_bounce() -> void:
	if _bounce_tween:
		return
		#_bounce_tween.kill()
	
	scale = Vector2.ONE

	# Infinite bounce cycle
	_bounce_tween = create_tween().set_loops()
	_bounce_tween.tween_property(self, "scale", _bounce_scale, _bounce_speed)
	_bounce_tween.tween_property(self, "scale", Vector2.ONE, _bounce_speed)

func _end_bounce() -> void:
	if not _bounce_tween:
		return
	_bounce_tween.kill()
	_bounce_tween = null
