extends RigidBody2D

var _hit_area: HitArea2D = null

func _ready() -> void:
	_init_hit_area()

func _init_hit_area():
	if has_node("HitArea2D"):
		_hit_area = $HitArea2D

func set_damage(damage: float) -> void:
	_hit_area.set_dealt_damage(damage)

func _on_hit_area_2d_hitted(area: Variant) -> void:
	queue_free()


func _on_hit_area_2d_body_entered(body: Node2D) -> void:
	queue_free()
