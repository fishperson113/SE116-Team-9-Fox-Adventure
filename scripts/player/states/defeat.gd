extends PlayerState

@onready var sfx_defeat: AudioStreamPlayer = $"../../SFX/Defeat"

func _enter() -> void:
	#Change animation to fall
	sfx_defeat.play()
	obj.velocity.x = 0
	obj.change_animation("defeat")
	pass

func _update(_delta: float) -> void:
	var scene = load("res://scenes/ui/LoseUI.tscn").instantiate()
	var nine_patch = scene.get_node("NinePatchRect")
	
	# Đảm bảo pause trước
	get_tree().paused = true
	
	# Add và đưa lên trên cùng
	get_tree().root.add_child(scene)
	
	if nine_patch:
		var viewport_size = get_viewport().get_visible_rect().size
		nine_patch.position = (viewport_size - nine_patch.size) / 2
	#if update_timer(_delta):
		#obj.get_tree().reload_current_scene()
	pass
