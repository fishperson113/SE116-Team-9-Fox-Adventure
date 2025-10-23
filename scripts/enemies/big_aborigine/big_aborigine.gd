extends Enemy

#Mô tả:
#Đứng im tại chỗ
#Khi phát hiện người chơi trong phạm vi Sight sẽ sử dụng khiên chắn trước mặt theo hướng của người chơi.
#Cứ 2 giây sẽ hướng phía người chơi và tấn công bằng giáo, phạm vi tấn công bằng Sight, 1 lần gây sát thương bằng Attack Damage và tốc độ bằng Attack Speed
#Khiên không thể bị phá vỡ
#Quái vật này chỉ có thể bị tấn công từ phía sau.

@export var stab_period: float = attack_time * 3 / 4

var attack_time: float = sight / attack_speed

var _detect_ray_cast: RayCast2D = null
var _stab_time: float = 0.0

@onready var _attack_box := $Direction/HitArea2D/CollisionShape2D
@onready var _attack_timer := $AttackTimer

func _ready() -> void:
	super._ready()
	_hit_area.set_dealt_damage(attack_damage)
	fsm=FSM.new(self,$States,$States/Normal)
	_init_detect_ray_cast()

func _init_detect_ray_cast():
	if has_node("Direction/DetectRayCast2D"):
		_detect_ray_cast = $Direction/DetectRayCast2D
		_detect_ray_cast.target_position.x = sight

func can_defend() -> bool:
	if _detect_ray_cast:
		return _detect_ray_cast.is_colliding()
	return false
	
func start_defend_mode():
	_animation_controller.change_animation("defend")
	pass
	
func end_defend_mode():
	pass
	
func update_defend_mode(_delta):
	pass

func _on_attack_timer_timeout() -> void:
	fsm.change_state(fsm.states.attack)

func start_attack_mode() -> void:
	_stab_time = stab_period
	_animation_controller.change_animation("attack")

func end_attack_mode() -> void:
	end_attack()
	_attack_timer.start()
	pass

func update_attack_mode(_delta: float) -> void:
	_stab_time -= _delta
	if _stab_time <= 0:
		attack()
	pass

func attack() -> void:
	_attack_box.disabled = false

func end_attack() -> void:
	_attack_box.disabled = true

func get_attack_time() -> float:
	return attack_time
