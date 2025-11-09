extends Node2D
class_name BaseCollectible

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("default")

func _on_interaction_available() -> void:
	print("Player touched the collectible")
	pass # Replace with function body.
