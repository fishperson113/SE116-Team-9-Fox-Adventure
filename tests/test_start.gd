extends Node2D
func _ready() -> void:
	$FadeOutBackground.play("fade_in")
	await $FadeOutBackground.animation_finished
	$FadeOutBackground/ColorRect.visible = false 
	
