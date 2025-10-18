extends Projectile
class_name ProjectileBlade

func _init() -> void:
	speed = 400
	gravity = 100
	spin_speed = 30

func _ready() -> void:
	_velocity = dir * speed
