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
@export var claw_speed: float = 250.0

var _slash_box: CollisionShape2D = null
var _slash_area: HitArea2D = null
var _slash_period: float = 0.0
var _has_slashed: bool = false

var _shoot_period: float = 0.3
var _has_shot: bool = false
var _recall_area: Area2D = null
var _bullet_factory : Node2DFactory = null

var _roll_box: CollisionShape2D = null
var _roll_area: HitArea2D = null

func _ready() -> void:
	super._ready();
	_init_state("Roll", start_roll, end_roll, update_roll, _on_normal_react)
	_init_state("StopRoll", start_stop_roll, end_stop_roll, update_stop_roll, _on_normal_react)
	_init_state("Shoot", start_shoot, end_shoot, update_shoot, _on_normal_react)
	_init_state("Recall", start_recall, end_recall, update_recall, _on_normal_react)
	_init_state("PrepareMeteor", start_prepare_meteor, end_prepare_meteor, update_prepare_meteor, _on_normal_react)
	_init_state("MeteorSlide", start_meteor_slide, end_meteor_slide, update_meteor_slide, _on_normal_react)
	_init_state("PrepareSlash", start_prepare_slash, end_prepare_slash, update_prepare_slash, _on_normal_react)
	_init_state("DeathSlash", start_death_slash, end_death_slash, update_death_slash, _on_normal_react)
	_init_death_slash_skill()
	_init_recall_skill()
	_init_roll_skill()
	_init_shoot_skill()

func _init_death_slash_skill():
	if has_node("Direction/SlashHitArea2D"):
		_slash_area = get_node("Direction/SlashHitArea2D")
		_slash_box = get_node("Direction/SlashHitArea2D/SlashCollisionShape2D")
		_slash_area.set_dealt_damage(spike)
		_slash_box.disabled = true
		_slash_period = slash_frame / animated_sprite.sprite_frames.get_animation_speed("slash")

func _init_recall_skill() -> void:
	if has_node("Direction/RecallArea2D"):
		_recall_area = get_node("Direction/RecallArea2D")

func _init_shoot_skill() -> void:
	if has_node("Direction/BulletFactory"):
		_bullet_factory = get_node("Direction/BulletFactory")

func _init_roll_skill() -> void:
	if has_node("Direction/RollHitArea2D"):
		_roll_area = get_node("Direction/RollHitArea2D")
		_roll_box = get_node("Direction/RollHitArea2D/RollCollisionShape2D")
		_roll_area.set_dealt_damage(spike)
		_roll_box.disabled = true

func _init_skill_set():
	super._init_skill_set()
	_short_range_skills = [fsm.states.roll, fsm.states.prepareslash, fsm.states.preparemeteor]
	_far_range_skills = [fsm.states.roll, fsm.states.shoot, fsm.states.preparemeteor]

# Normal state
func update_normal(_delta: float):
	if not found_player:
		return
	_follow_player()
	super.update_normal(_delta)

func _follow_player() -> void:
	if is_player_visible():
		target(found_player.position)
		hold_distance_from_player()
		try_jump()

func try_jump() -> bool:
	return jump_over_wall() or jump_over_hole()

func jump_over_hole() -> bool:
	if not is_can_fall():
		return false
	jump()
	return true

func jump_over_wall() -> bool:
	return super.try_jump()

# Roll state
func start_roll() -> void:
	_roll_box.disabled = false
	_movement_speed = movement_speed
	change_animation("roll")
	pass

func end_roll() -> void:
	_roll_box.disabled = true
	pass

func update_roll(_delta: float) -> void:
	_movement_speed += roll_accelerator * _delta
	if try_jump():
		return
	if not found_player or not is_on_direction(found_player.position) or is_on_wall():
		fsm.change_state(fsm.states.stoproll)
	pass

# Stop roll state
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

# Shoot state
func start_shoot() -> void:
	_has_shot = false
	stop_move()
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

# Recall state
func start_recall() -> void:
	stop_move()
	change_animation("recall")
	animated_sprite.animation_finished.connect(_return_to_normal)
	
func end_recall() -> void:
	animated_sprite.animation_finished.disconnect(_return_to_normal)
	pass

func update_recall(_delta: float) -> void:
	pass

func shoot() -> void:
	if not found_player:
		return
	if _has_shot:
		return
	
	_has_shot = true
	var bullet := _bullet_factory.create() as Claw
	bullet.set_launcher(self)
	bullet.set_damage(spike)
	bullet.set_gravity(0)
	bullet.set_range(claw_range)
	bullet.set_target(found_player.global_position, claw_speed)

func recall(body: Node2D) -> void:
	if body is Claw and body.is_returning():
		body.attach()
		fsm.change_state(fsm.states.recall)
	pass

# Prepare meteor state
func start_prepare_meteor() -> void:
	change_animation("roll");
	prepare_meteor_jump()
	pass

func update_prepare_meteor(_delta: float) -> void:
	if velocity.y >= 0:
		fsm.change_state(fsm.states.meteorslide)
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

# Slide state
func start_meteor_slide() -> void:
	_roll_box.disabled = false
	change_animation("roll");
	meteor_slide()
	pass

func update_meteor_slide(_delta: float) -> void:
	if is_on_floor():
		fsm.change_state(fsm.states.stoproll)
	pass

func end_meteor_slide() -> void:
	_roll_box.disabled = true
	pass

func meteor_slide():
	if not found_player:
		return
	
	target(found_player.position)
	var slide_speed = compute_shot_speed(self.position, found_player.position, meteor_slide_speed)
	_movement_speed = abs(slide_speed.x)
	velocity.y = slide_speed.y
	pass

# Prepare slash state
func start_prepare_slash() -> void:
	start_normal()
	pass

func update_prepare_slash(_delta: float) -> void:
	if not is_player_visible():
		_return_to_normal()
		return
	_follow_player()
	if is_close(found_player.global_position, _get_slash_range()):
		fsm.change_state(fsm.states.deathslash)
	pass

func end_prepare_slash() -> void:
	pass

# Slash state
func start_death_slash() -> void:
	_has_slashed = false
	stop_move()
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

func _get_slash_range() -> float:
	return absf(_slash_box.position.x) + _slash_box.shape.size.x / 2
