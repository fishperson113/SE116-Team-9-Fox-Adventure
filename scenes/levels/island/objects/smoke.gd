extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	queue_free()
