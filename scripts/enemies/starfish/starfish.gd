extends Enemy

#Mô tả:
#Đi qua đi lại trong 1 phạm vi nhất định
#Nếu phát hiện người chơi trong Sight sẽ cuộn tròn và lăn về phía người chơi, tăng 50% tốc di chuyển khi đang lăn
#Chạm vào người chơi sẽ dừng lại 1 giây trước khi tiếp tục hành động tiếp.
#Người chơi chạm vào sẽ bị mất máu theo Spike
#Không được di chuyển quá Movement Range cho phép
#Không có khả năng tấn công

@export var attack_speed_multiplier: float = 1.5
@export var stun_time: float = 1

var _roll_box: CollisionShape2D = null
var _normal_box: CollisionShape2D = null
var _sight_ray_cast: RayCast2D = null

func _ready() -> void:
	super._ready()
	_init_sight_ray_cast()
	_init_attack_box()
	
func _init_sight_ray_cast():
	if has_node("Direction/SightRayCast2D"):
		_sight_ray_cast = $Direction/SightRayCast2D
		_sight_ray_cast.target_position.x = sight

func _init_attack_box():
	if has_node("Direction/HitArea2D/RollCollisionShape2D"):
		_roll_box = $Direction/HitArea2D/RollCollisionShape2D
	if has_node("Direction/HitArea2D/NormalCollisionShape2D"):
		_normal_box = $Direction/HitArea2D/NormalCollisionShape2D

func _on_hit_area_2d_hitted(area: Variant) -> void:
	fsm.changing_signals["hit"] = true

func get_stun_time() -> float:
	return stun_time

func can_attack() -> bool:
	return _sight_ray_cast.is_colliding()

func start_attack_mode() -> void:
	_movement_speed *= attack_speed_multiplier
	
	_normal_box.disabled = true
	_roll_box.disabled = false
	
	_animation_controller.change_animation("attack")

func end_attack_mode() -> void:
	_movement_speed /= attack_speed_multiplier
	
	_roll_box.disabled = true
	_normal_box.disabled = false

func update_attack_mode(_delta: float) -> void:
	#try_patrol_turn(_delta)
	pass

func start_stun_mode() -> void:
	_movement_speed = 0
	_animation_controller.change_animation("stun")
	pass

func end_stun_mode() -> void:
	pass
	
func update_stun_mode(_delta: float) -> void:
	pass
