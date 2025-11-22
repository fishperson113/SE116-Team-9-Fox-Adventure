extends Node2D

@export var smoke_effect: PackedScene


func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer/ColorRect.visible = false


func _on_level_chosen(level_num: int):
	hide()

	load_level(level_num)


func add_smoke_effect(pos: Vector2):
	if smoke_effect == null:
		push_error("smoke_effect chưa được gán trong Inspector!")
		return
		
	var smoke_fx = smoke_effect.instantiate()
	smoke_fx.position = pos
	add_child(smoke_fx)


func load_level(num: int):
	var level_path := "res://scenes/levels/level_%d/stage_1.tscn" % num

	if not ResourceLoader.exists(level_path):
		push_error("❌ Level path không tồn tại: " + level_path)
		return

	var error := get_tree().change_scene_to_file(level_path)

	if error != OK:
		push_error("❌ change_scene_to_file bị lỗi: %s" % error)
