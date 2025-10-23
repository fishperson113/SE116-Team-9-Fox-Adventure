extends Enemy

#-	Mô tả:
#Đứng im tại chỗ không thể di chuyển
#Khi phát hiện Player trong Sight sẽ bắn 3 viên đạn nước liên tiếp về phía người chơi.
#Mỗi viên sẽ có tốc độ bay bằng Attack Speed và sát thương bằng Attack Damage
#Cooldown 3 giây (bất kể người chơi có ở trong Sight hay không).

@export var _shoot_time: float = 0.5
@export var _shoot_interval: float = 0.5
@export var _attack_cool_down: float = 3.0

var _sight_ray_cast: RayCast2D = null
var _cooldown: float = 0.0

@onready var _bullet_factory := $Direction/BulletFactory

func _ready() -> void:
	super._ready()
	fsm=FSM.new(self,$States,$States/Normal)
	_init_sight_ray_cast()

func _init_sight_ray_cast():
	if has_node("Direction/SightRayCast2D"):
		_sight_ray_cast = $Direction/SightRayCast2D
		_sight_ray_cast.target_position.x = sight

func fire():
	var bullet = _bullet_factory.create() as Bullet
	bullet.apply_velocity(Vector2(attack_speed * _direction_controller.get_direction(), 0.0))
	bullet.set_damage(attack_damage)

#func start_normal_mode() -> void:
	#_animation_controller.change_animation("normal")

func update_normal_mode(_delta: float) -> void:
	pass
	
func get_shoot_time() -> float:
	return _shoot_time

func get_attack_cooldown() -> float:
	return _attack_cool_down

func start_attack_mode() -> void:
	_animation_controller.change_animation("attack")
	_cooldown = _shoot_interval

func end_attack_mode() -> void:
	pass

func update_attack_mode(_delta: float) -> void:
	_cooldown -= _delta
	if _cooldown <= 0:
		_cooldown += _shoot_interval
		fire()

func can_attack() -> bool:
	if _sight_ray_cast:
		return _sight_ray_cast.is_colliding()
	return false
