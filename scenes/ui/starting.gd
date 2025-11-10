extends Node2D

@export var smoke_effect: PackedScene  

func _on_level_chosen(level_num: int):
	hide()
	await  get_tree().process_frame
	load_level(level_num)

func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer/ColorRect.visible = false 
	
func _process(delta: float) -> void:
	pass	
	
func _physics_process(delta: float) -> void:
	pass
	
func add_smoke_effect(pos: Vector2):
	var smoke_fx = smoke_effect.instantiate()
	smoke_fx.position = pos
	add_child(smoke_fx)

func load_level(num: int):
	var level_path = "res://scenes/levels/level_" + str(num) + "/stage_1.tscn"
	
	if ResourceLoader.exists(level_path):
		await get_tree().process_frame 
		get_tree().change_scene_to_file(level_path)
	else:
		push_error("Level path không tồn tại: " + level_path)
