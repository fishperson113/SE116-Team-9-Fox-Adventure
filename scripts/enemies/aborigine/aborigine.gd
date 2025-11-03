extends Enemy

#Mô tả:
#Đi qua lại trong phạm vi nhất định
#Vừa di chuyển vừa tấn công
#Mỗi giây lại ném 2 quả dừa sang 2 bên theo khoảng cách Movement Distance
#Tốc độ bay của quả dừa sẽ dựa trên Attack Speed
#Đường bay của của dừa sẽ hình vòng cung, bay lên trời rùi mới đáp xuống đất.
#Quả dừa sẽ tự biến mất khi tiếp xúc với mặt đất
#Nếu người chơi chạm vào quả dừa thì sẽ bị mất máu theo Attack Damage

@export var shoot_time: float = 0.4
@export var shoot_cooldown: float = 1.0
@export var attack_time: float = 0.8
@export var stab_period: float = 0.6
@export var bullet_up_impulse: float = -20

var _detect_ray_cast: RayCast2D = null
var _stab_time: float = 0.0

@onready var _attack_box := $Direction/HitArea2D/CollisionShape2D
@onready var _left_factory := $Direction/LeftFactory
@onready var _right_factory := $Direction/RightFactory

func _ready() -> void:
	super._ready()
	fsm=FSM.new(self,$States,$States/Normal)
	_init_detect_ray_cast()

func _init_detect_ray_cast():
	if has_node("Direction/DetectRayCast2D"):
		_detect_ray_cast = $Direction/DetectRayCast2D

func start_attack_mode() -> void:
	_movement_speed = movement_speed
	_stab_time = stab_period
	_animation_controller.change_animation("attack")

func end_attack_mode() -> void:
	end_attack()
	pass

func update_attack_mode(_delta: float) -> void:
	try_patrol_turn(_delta)
	_stab_time -= _delta
	if _stab_time <= 0:
		attack()
	pass

func attack() -> void:
	_attack_box.disabled = false

func end_attack() -> void:
	_attack_box.disabled = true

func can_attack() -> bool:
	if _detect_ray_cast:
		return _detect_ray_cast.is_colliding()
	return false

func get_attack_time() -> float:
	return attack_time

func get_shoot_cooldown() -> float:
	return shoot_cooldown

func get_shoot_time() -> float:
	return shoot_time

func start_throw_mode() -> void:
	_movement_speed = 0.0
	throw()
	_animation_controller.change_animation("throw")
	pass
	
func end_throw_mode() -> void:
	pass

func update_throw_mode() -> void:
	pass

func throw() -> void:
	var leftCoconut = _left_factory.create() as RigidBody2D
	var rightCoconut = _right_factory.create() as RigidBody2D
	leftCoconut.apply_impulse(Vector2(-_direction_controller.get_direction() * attack_speed, bullet_up_impulse))
	rightCoconut.apply_impulse(Vector2(_direction_controller.get_direction() * attack_speed, bullet_up_impulse))
	leftCoconut.set_damage(attack_damage)
	rightCoconut.set_damage(attack_damage)
