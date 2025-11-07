extends Node2D
func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer/ColorRect.visible = false 
	
