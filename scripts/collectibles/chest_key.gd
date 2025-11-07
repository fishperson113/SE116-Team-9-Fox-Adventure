extends Collectible

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("default")

func is_effect(body: Node2D) -> void:
	if body is Player:
		body.inventory.insert_item(false, "chest_key")
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	is_effect(body)
	pass # Replace with function body.
