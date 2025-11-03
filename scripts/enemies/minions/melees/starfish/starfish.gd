extends StatefulEnemy

#Mô tả:
#Đi qua đi lại trong 1 phạm vi nhất định
#Nếu phát hiện người chơi trong Sight sẽ cuộn tròn và lăn về phía người chơi, tăng 50% tốc di chuyển khi đang lăn
#Chạm vào người chơi sẽ dừng lại 1 giây trước khi tiếp tục hành động tiếp.
#Người chơi chạm vào sẽ bị mất máu theo Spike
#Không được di chuyển quá Movement Range cho phép
#Không có khả năng tấn công

@export var attack_speed_multiplier: float = 1.5

@export var stun_time: float = 1

@onready var _roll_box: CollisionShape2D = $Direction/HitArea2D/RollCollisionShape2D
@onready var _normal_box: CollisionShape2D = $Direction/HitArea2D/NormalCollisionShape2D
@onready var _detect_ray_cast: RayCast2D = $Direction/DetectRayCast2D

func _ready() -> void:
	super._ready()
	fsm=FSM.new(self,$States,$States/Normal)
	_init_detect_ray_cast()
	_init_hit_area()
	_init_attack_state()
	_init_stun_state()

func _init_hit_area():
	var hit_area := $Direction/HitArea2D
	hit_area.set_dealt_damage(spike)
	hit_area.hitted.connect(_on_hit_area_2d_hitted)

func _init_attack_state() -> void:
	if has_node("States/Attack"):
		var state : EnemyState = get_node("States/Attack")
		state.enter.connect(start_attack)
		state.exit.connect(end_attack)
		state.update.connect(update_attack)

func _init_stun_state() -> void:
	if has_node("States/Stun"):
		var state : EnemyState = get_node("States/Stun")
		state.enter.connect(start_stun)
		state.exit.connect(end_stun)
		state.update.connect(update_stun)

func _init_detect_ray_cast():
	_detect_ray_cast.target_position.x = sight

func _on_hit_area_2d_hitted(area: Variant) -> void:
	fsm.change_state(fsm.states.stun)

func get_stun_time() -> float:
	return stun_time

func can_attack() -> bool:
	return _detect_ray_cast.is_colliding()

func start_attack() -> void:
	_movement_speed *= attack_speed_multiplier
	
	_normal_box.disabled = true
	_roll_box.disabled = false
	
	change_animation("attack")

func end_attack() -> void:
	_movement_speed /= attack_speed_multiplier
	
	_roll_box.disabled = true
	_normal_box.disabled = false

func update_attack(_delta: float) -> void:
	pass

func start_stun() -> void:
	_movement_speed = 0
	change_animation("stun")
	pass

func end_stun() -> void:
	pass
	
func update_stun(_delta: float) -> void:
	pass
