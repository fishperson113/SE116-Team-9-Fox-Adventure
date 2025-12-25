class_name BigLootWrapper
extends EffectWrapper

func play_effect() -> void:
	var vertical_speed: float = randf_range(-200, -1000)
	var horizontal_speed: float = randf_range(-400, 400)
	apply_impulse(Vector2(horizontal_speed, vertical_speed))
