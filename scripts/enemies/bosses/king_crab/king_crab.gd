extends Boss

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

@export var stun_time: float = 2.0
@export var detect_distance_tolerance: float = 16.0

@export_group("Rolling skill")
@export var roll_accelerator: float = 100
@export var roll_decelerator: float = 100

@export_group("Meteor slide skill")
@export var prepare_meteor_time: float = 1.75
@export var meteor_slide_speed: float = 1000

@export_group("Death slash skill")
@export var slash_frame: int = 3

@export_group("Launch claw skill")
@export var claw_frame: int = 3
@export var claw_range: float = 600.0
@export var claw_speed: float = 400.0

var _slash_box: CollisionShape2D = null
var _slash_period: float = 0.0
var _has_slashed: bool = false

var _shoot_period: float = 0.0
var _has_shot: bool = false
var _recall_area: Area2D = null
var _bullet_factory : Node2DFactory = null

func _ready() -> void:
	super._ready();
	_init_roll_state()
	_init_stop_roll_state()
	_init_shoot_state()
	_init_recall_state()
	_init_stun_state()
	_init_prepare_meteor_state()
	_init_meteor_slide_state()
	_init_prepare_slash_state()
	_init_death_slash_state()

func _init_death_slash_state():
	if has_node("States/DeathSlash"):
		var state : EnemyState = get_node("States/DeathSlash")
		state.enter.connect(start_death_slash)
		state.exit.connect(end_death_slash)
		state.update.connect(update_death_slash)
	
	if has_node("Direction/HitArea2D/SlashCollisionShape2D"):
		_slash_box = get_node("Direction/HitArea2D/SlashCollisionShape2D")
		_slash_box.disabled = true
		_slash_period = slash_frame / animated_sprite.sprite_frames.get_animation_speed("slash")

func _init_prepare_slash_state():
	if has_node("States/PrepareSlash"):
		var state : EnemyState = get_node("States/PrepareSlash")
		state.enter.connect(start_prepare_slash)
		state.exit.connect(end_prepare_slash)
		state.update.connect(update_prepare_slash)

func _init_meteor_slide_state():
	if has_node("States/Slide"):
		var state : EnemyState = get_node("States/Slide")
		state.enter.connect(start_meteor_slide)
		state.exit.connect(end_meteor_slide)
		state.update.connect(update_meteor_slide)

func _init_prepare_meteor_state():
	if has_node("States/PrepareMeteor"):
		var state : EnemyState = get_node("States/PrepareMeteor")
		state.enter.connect(start_prepare_meteor)
		state.exit.connect(end_prepare_meteor)
		state.update.connect(update_prepare_meteor)

func _init_stun_state() -> void:
	if has_node("States/Stun"):
		var state : EnemyState = get_node("States/Stun")
		state.enter.connect(start_stun)
		state.exit.connect(end_stun)
		state.update.connect(update_stun)

func _init_recall_state() -> void:
	if has_node("States/Recall"):
		var state : EnemyState = get_node("States/Recall")
		state.enter.connect(start_recall)
		state.exit.connect(end_recall)
	
	if has_node("Direction/RecallArea2D"):
		_recall_area = get_node("Direction/RecallArea2D")

func _init_shoot_state() -> void:
	if has_node("States/Shoot"):
		var state : EnemyState = get_node("States/Shoot")
		state.enter.connect(start_shoot)
		state.exit.connect(end_shoot)
		state.update.connect(update_shoot)
		_shoot_period = claw_frame / animated_sprite.sprite_frames.get_animation_speed("shoot")
	if has_node("Direction/BulletFactory"):
		_bullet_factory = get_node("Direction/BulletFactory")

func _init_roll_state() -> void:
	if has_node("States/Roll"):
		var state : EnemyState = get_node("States/Roll")
		state.enter.connect(start_roll)
		state.exit.connect(end_roll)
		state.update.connect(update_roll)

func _init_stop_roll_state() -> void:
	if has_node("States/StopRoll"):
		var state : EnemyState = get_node("States/StopRoll")
		state.enter.connect(start_stop_roll)
		state.exit.connect(end_stop_roll)
		state.update.connect(update_stop_roll)

func _init_skill_set():
	super._init_skill_set()
	_skill_set = [fsm.states.roll, fsm.states.shoot, fsm.states.preparemeteor, fsm.states.prepareslash]

func update_normal(_delta: float):
	try_patrol_turn(_delta)
	super.update_normal(_delta)

func try_patrol_turn(_delta: float) -> bool:
	if hold_range():
		return false
	if try_jump():
		return false
	if is_touch_wall() or is_can_fall() or want_to_turn():
		turn()
		return true
	return false

func try_jump() -> bool:
	return jump_over_wall() or jump_over_hole()

func jump_over_hole() -> bool:
	if not is_can_fall():
		return false
	jump()
	return true

func jump_over_wall() -> bool:
	return super.try_jump()

func start_roll() -> void:
	_movement_speed = movement_speed
	change_animation("roll")
	pass

func end_roll() -> void:
	pass

func update_roll(_delta: float) -> void:
	_movement_speed += roll_accelerator * _delta
	if try_jump():
		return
	if found_player:
		if _compute_target_direction(found_player.position) != direction:
			fsm.change_state(fsm.states.stoproll)
	pass

func start_stop_roll() -> void:
	change_animation("stop_roll");
	pass

func update_stop_roll(_delta: float) -> void:
	_movement_speed -= roll_decelerator * _delta
	if _movement_speed <= movement_speed or is_on_wall():
		_return_to_normal()
	pass

func end_stop_roll() -> void:
	pass

func start_shoot() -> void:
	_has_shot = false
	_movement_speed = 0
	change_animation("shoot")
	_recall_area.body_entered.connect(recall)
	fsm.current_state.timer = _shoot_period

func end_shoot() -> void:
	_recall_area.body_entered.disconnect(recall)
	pass

func update_shoot(_delta: float) -> void:
	if fsm.current_state.update_timer(_delta):
		shoot()
	pass

func start_recall() -> void:
	_movement_speed = 0
	change_animation("recall")
	animated_sprite.animation_finished.connect(_return_to_rest)
	
func end_recall() -> void:
	animated_sprite.animation_finished.disconnect(_return_to_rest)
	pass

func start_stun() -> void:
	_movement_speed = 0
	change_animation("stun")
	fsm.current_state.timer = stun_time

func update_stun(_delta: float) -> void:
	if fsm.current_state.update_timer(_delta):
		_return_to_normal()
	pass

func end_stun() -> void:
	pass

func shoot() -> void:
	if _has_shot:
		return
	
	_has_shot = true
	var bullet := _bullet_factory.create() as Claw
	bullet.set_launcher(self)
	bullet.set_damage(spike)
	bullet.apply_velocity(Vector2(claw_speed, 0.0))
	bullet.set_gravity(0)
	bullet.set_direction(direction)
	bullet.set_range(claw_range)

func recall(body: Node2D) -> void:
	if body is Claw and body.is_returning():
		body.attach()
		fsm.change_state(fsm.states.recall)

func start_prepare_meteor() -> void:
	change_animation("roll");
	prepare_meteor_jump()
	pass

func update_prepare_meteor(_delta: float) -> void:
	if velocity.y >= 0:
		#fsm.change_state(fsm.states.meteor)
		fsm.change_state(fsm.states.slide)
	pass

func end_prepare_meteor() -> void:
	pass

func prepare_meteor_jump() -> void:
	if not found_player:
		return
	
	target(found_player.position)
	var _computed_speed = compute_speed(prepare_meteor_time, found_player.position - self.position, gravity)
	_movement_speed = abs(_computed_speed.x)
	velocity.y = _computed_speed.y
	
func start_meteor_slide() -> void:
	change_animation("roll");
	meteor_slide()
	pass

func update_meteor_slide(_delta: float) -> void:
	if is_on_floor():
		fsm.change_state(fsm.states.stoproll)
	pass

func end_meteor_slide() -> void:
	pass

func meteor_slide():
	if not found_player:
		return
	
	target(found_player.position)
	var slide_speed = compute_shot_speed(self.position, found_player.position, meteor_slide_speed)
	_movement_speed = abs(slide_speed.x)
	velocity.y = slide_speed.y
	pass

func start_prepare_slash() -> void:
	start_normal()
	pass

func update_prepare_slash(_delta: float) -> void:
	if hold_range():
		fsm.change_state(fsm.states.deathslash)
	pass

func end_prepare_slash() -> void:
	pass

func start_death_slash() -> void:
	_has_slashed = false
	_movement_speed = 0.0
	change_animation("slash");
	animated_sprite.animation_finished.connect(_return_to_normal)
	fsm.current_state.timer = _slash_period
	pass

func update_death_slash(_delta: float) -> void:
	if fsm.current_state.update_timer(_delta):
		death_slash()
	pass

func end_death_slash() -> void:
	_slash_box.disabled = true
	animated_sprite.animation_finished.disconnect(_return_to_normal)
	pass

func death_slash():
	if _has_slashed:
		return
	
	_has_slashed = true
	_slash_box.disabled = false
	pass

func hold_range():
	if not found_player:
		return false
	
	if not is_near(found_player.position):
		_movement_speed = movement_speed
		return false
	
	_movement_speed = -movement_speed
	return true

func is_near(_pos: Vector2):
	var _size = get_size()
	var _left = position.x - _size.x / 2
	var _right = _left + _size.x
	return _pos.x + detect_distance_tolerance >= _left and _pos.x - detect_distance_tolerance <= _right
