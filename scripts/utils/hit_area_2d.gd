extends Area2D
class_name HitArea2D

# damage of hit
var _dealt_damage: float = 1

# signal when hit area
signal hitted(area)

func _init() -> void:
	area_entered.connect(_on_area_entered)

# called when hit area
func hit(hurt_area):
	if(hurt_area.has_method("take_damage")):
		var hit_dir:Vector2 = hurt_area.global_position - global_position
		hurt_area.take_damage(hit_dir.normalized(), _dealt_damage)

# called when area entered
func _on_area_entered(area):
	hit(area)
	hitted.emit(area)

func set_dealt_damage(dealt_damage: float) -> void:
	_dealt_damage = dealt_damage
