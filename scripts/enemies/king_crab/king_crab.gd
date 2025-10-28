extends Enemy

#Hành Vi
#Chạm vào người chơi: Người chơi bị mất máu theo Spike
#Skill 1:
#	Cuộn tròn và lăn về phía màn hình đối diện với tốc độ di chuyển bằng Move Speed. 
#	Dừng lại khi chạm vào giới hạn tối đa của màn hình Boss Scene
#Skill 2:
#	Phóng chiếc càng lớn rời ra bay về phía góc còn lại của màn hình với Move Speed và Attack Range, khi đạt Attack Range tối đa sẽ tự động bay trở về vị trí cũ với Move Speed không đổi.
#	Chiếc càng rời ra khi chạm vào người chơi cũng làm họ mất máu theo Spike
#	Chiếc càng này không thể bị phá huỷ, chỉ có thể né tránh
#	Sau khi sử dụng Skill 2 sẽ vào trạng thái mệt mỏi trong 2 giây.
#Boss King Crab sẽ sử dụng Skill 1 và Skill 2 đan xen nhau

@export var rolling_time: float = 2.0
@export var stop_rolling_time: float = 0.4
@export var idle_time: float = 2.0
@export var shoot_period: float = 0.6
@export var recall_time: float = 0.4
@export var stun_time: float = 2.0
@export var attack_range: float = 150.0

var _skill_set = []
var _skill_cursor = 0

var _is_attaching := false

@onready var _roll_box := $Direction/HitArea2D/CollisionShape2D
@onready var bullet_factory := $Direction/BulletFactory
@onready var _action_timer := $ActionTimer

func _ready() -> void:
	super._ready();
	fsm = FSM.new(self, $States, $States/Normal);
	_set_up_skill_set()

func _set_up_skill_set():
	_skill_set = [fsm.states.roll, fsm.states.shoot]
	_skill_cursor = 0

func start_roll_mode() -> void:
	_roll_box.disabled = false;
	_movement_speed = movement_speed;
	_animation_controller.change_animation("roll");
	pass

func end_roll_mode() -> void:
	_roll_box.disabled = true;
	_change_skill()
	pass

func update_roll_mode(_delta) -> void:
	pass

func start_stop_roll_mode() -> void:
	_movement_speed = 0;
	_animation_controller.change_animation("stop_roll");
	pass

func end_stop_roll_mode() -> void:
	pass

func update_stop_roll_mode(_delta) -> void:
	pass

func start_normal_mode() -> void:
	_movement_speed = movement_speed / 2
	_animation_controller.change_animation("normal")

func end_normal_mode() -> void:
	pass

func update_normal_mode(_delta: float) -> void:
	if is_environment_detected():
		_direction_controller.turn_around()
	pass
	
func start_shoot_mode() -> void:
	_movement_speed = 0
	
	_action_timer.wait_time = shoot_period
	_action_timer.start()
	_action_timer.timeout.connect(shoot)
	
	_animation_controller.change_animation("shoot")

func end_shoot_mode() -> void:
	_change_skill()
	pass

func update_shoot_mode(_delta: float) -> void:
	pass

func start_recall_mode() -> void:
	_movement_speed = 0
	_animation_controller.change_animation("recall")

func end_recall_mode() -> void:
	_is_attaching = false
	pass

func update_recall_mode(_delta: float) -> void:
	pass

func start_stun_mode() -> void:
	_movement_speed = 0
	_animation_controller.change_animation("stun")

func end_stun_mode() -> void:
	pass

func update_stun_mode(_delta: float) -> void:
	pass

func get_current_skill():
	return _skill_set[_skill_cursor]

func _change_skill():
	_skill_cursor = (_skill_cursor + 1) % _skill_set.size()

func shoot() -> void:
	var bullet := bullet_factory.create() as Claw
	bullet.set_damage(spike)
	bullet.apply_velocity(Vector2(movement_speed, 0.0))
	bullet.set_direction(_direction_controller.get_direction())
	bullet.set_range(attack_range)

func is_attaching() -> bool:
	return _is_attaching

func _on_recall_area_2d_body_entered(body: Node2D) -> void:
	if body is Claw:
		var claw := body as Claw
		_is_attaching = true
		claw.attach()
