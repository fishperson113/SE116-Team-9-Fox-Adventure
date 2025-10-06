class_name AnimationController
extends Node2D

var _animated_sprite_2D: AnimatedSprite2D = null
var _current_animation_name = null
var _next_animation_name = null

func _init(animated_sprite_2D: AnimatedSprite2D) -> void:
	_animated_sprite_2D = animated_sprite_2D

func _update(_delta: float) -> void:
	_check_changed_animation()

func change_animation(new_animation_name: String) -> void:
	_next_animation_name = new_animation_name
	
func get_animation_name() -> String:
	return _current_animation_name
	
func _check_changed_animation() -> void:
	var need_play: bool = _check_changed_animation_name()
	if need_play and _current_animation_name != null:
		_animated_sprite_2D.play(_current_animation_name)

func _check_changed_animation_name() -> bool:
	if _next_animation_name != _current_animation_name:
		_current_animation_name = _next_animation_name
		return true
	return false
