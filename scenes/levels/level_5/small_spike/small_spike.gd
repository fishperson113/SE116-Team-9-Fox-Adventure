extends Node2D

@export var base_damage: float = 1
@export var safe_speed: float = 800

var _hit_area: SmallSpikeHitArea2D = null

func _ready() -> void:
	_init_hit_area()
	pass
	
func _init_hit_area():
	if has_node("HitArea2D"):
		_hit_area = get_node("HitArea2D") as SmallSpikeHitArea2D
		_hit_area.hitting.connect(_on_hit_area_hitting)
		_hit_area.set_target_name("Player")
		_hit_area.set_condition(_is_player_too_fast)

func _on_hit_area_hitting(body: BaseCharacter):
	_hit_area.set_dealt_damage(_compute_damage(body.old_velocity.y))
	print(_compute_damage(body.old_velocity.y))
	pass

func _compute_damage(speed: float) -> float:
	var exceeded_speed = maxf(0, absf(speed) - safe_speed)
	return base_damage * exceeded_speed

func _is_player_too_fast(body: BaseCharacter):
	print("speed check: ", body.old_velocity.y)
	return absf(body.old_velocity.y) >= safe_speed
