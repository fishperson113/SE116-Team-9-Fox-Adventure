extends Node2D
@export_file("*.tscn") var target_stage = ""
@export var target_door = "Door"
@onready var animated_sprite = $AnimatedSprite2D
@export var key_signal: Sprite2D

@onready var sfx_win: AudioStreamPlayer = $Win

var player_in_area = false
var win_ui_shown = false  

func _ready() -> void:
	animated_sprite.play("idle")
	key_signal.visible = false

func _process(delta):
	pass

func load_next_stage():
	var current_stage_path = get_tree().current_scene.scene_file_path
	
	if target_stage == current_stage_path:
		move_player_to_door()
	else:
		GameManager.change_stage(target_stage, target_door)

func move_player_to_door():
	var player = get_tree().current_scene.find_child("Player", true, false)
	if not player:
		printerr("Không tìm thấy node có tên là 'Player' trong scene!")
		return
	var target_door_node = get_tree().current_scene.find_child(target_door, true, false)
	if not target_door_node:
		printerr("Không tìm thấy cửa đến với tên: '", target_door, "' trong scene!")
		return
	var spawn_point = target_door_node.get_node_or_null("SpawnPoint")
	if spawn_point:
		player.global_position = spawn_point.global_position
	else:
		player.global_position = target_door_node.global_position
	
	print("Đã di chuyển người chơi đến cửa: ", target_door)

func _on_interactive_area_2d_interacted() -> void:
	sfx_win.play()
	GameManager.unlock_level()
	if player_in_area and not win_ui_shown:
		win_ui_shown = true 
		var scene = load("res://scenes/ui/WinUI.tscn").instantiate()
		get_tree().root.add_child(scene)
		var nine_patch = scene.get_node("NinePatchRect")
		if nine_patch:
			var viewport_size = get_viewport().get_visible_rect().size
			nine_patch.position = (viewport_size - nine_patch.size) / 2
	print("is it unlocking a new level?")

func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = true
		animated_sprite.play("opening")
		key_signal.visible = true

func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = false
		win_ui_shown = false  
		animated_sprite.play("closing")
		key_signal.visible = false
		await animated_sprite.animation_finished
		if animated_sprite.animation == "closing":
			animated_sprite.play("idle")
