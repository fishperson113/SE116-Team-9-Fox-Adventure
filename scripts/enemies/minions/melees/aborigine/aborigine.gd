extends ShootableEnemy

#Mô tả:
#Đi qua lại trong phạm vi nhất định
#Vừa di chuyển vừa tấn công
#Mỗi giây lại ném 2 quả dừa sang 2 bên theo khoảng cách Movement Distance
#Tốc độ bay của quả dừa sẽ dựa trên Attack Speed
#Đường bay của của dừa sẽ hình vòng cung, bay lên trời rùi mới đáp xuống đất.
#Quả dừa sẽ tự biến mất khi tiếp xúc với mặt đất
#Nếu người chơi chạm vào quả dừa thì sẽ bị mất máu theo Attack Damage

@export var bullet_up_impulse: float = -400.0

@onready var _left_factory := $Direction/LeftFactory
@onready var _right_factory := $Direction/RightFactory

func _ready() -> void:
	super._ready()

func start_shoot() -> void:
	_movement_speed = 0.0
	fire()
	change_animation("shoot")
	pass

func update_shoot(_detal: float) -> void:
	pass

func end_shoot() -> void:
	_shoot_timer.wait_time = randf_range(shoot_cooldown, shoot_cooldown + 1)
	super.end_shoot()
	pass

func fire() -> void:
	var leftCoconut = _left_factory.create() as RigidBody2D
	var rightCoconut = _right_factory.create() as RigidBody2D
	leftCoconut.apply_impulse(Vector2(-direction * attack_speed, bullet_up_impulse))
	rightCoconut.apply_impulse(Vector2(direction * attack_speed, bullet_up_impulse))
	leftCoconut.set_damage(attack_damage)
	rightCoconut.set_damage(attack_damage)

func can_attack() -> bool:
	return _is_ready

func try_attack() -> void:
	if can_attack():
		fsm.change_state(fsm.states.shoot)
