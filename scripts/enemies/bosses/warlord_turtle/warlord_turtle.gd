extends Boss

#Hành Vi:
#Boss Warlord Turtle sẽ đứng cố định giữa màn hình và không di chuyển
#Chạm vào người chơi: Người chơi bị mất máu theo Spike
#Skill 1:
#	Thả 2 quả bomb từ khẩu pháo to bự sau lưng, 1 quả sẽ lăn sang bên trái & 1 quả sẽ lăn sang bên phải theo Move Speed
#	Nếu người chơi chạm vào Bomb sẽ phát nổ và mất máu theo Spike
#	Người chơi có thể chém vào quả Bomb để khiến nó đổi hướng
#	Quả bomb sẽ không thể bị phá huỷ, nó sẽ bị huỷ khi phát nổ, tức nếu chạm vào một nhân vật bất kỳ hoặc đụng phải kích thước tối đa của màn hình Boss Scene
#	Sau khi sử dụng Skill 1 sẽ chuyển sang sử dụng Skill 2.
#Skill 2:
#	Phóng ra 4 quả tên lửa từ mai bay lên trời với tốc độ Attack Speed và tấn công xuống 4 vị trí cố định trên màn hình (A, B, C, D)
#	4 vị trí này sẽ được setup trong phần tạo map
#	Sát thương gây ra bằng Attack Damage
#	Sau khi sử dụng Skill 2 sẽ rơi vào trạng thái mệt mỏi 2 giây.
#Boss Warlord Turtle sẽ sử dụng Skill 1 và Skill 2 đan xen nhau

@export_group("Bomb frame")
@export var start_bomb_frame: int = 3
@export var bomb_frame_interval: int = 1

@export_group("Rocket frame")
@export var start_rocket_frame: int = 4
@export var rocket_frame_interval: int = 1

@export_group("Shoot bomb skill")
@export var shot_speed: float = 600

@export_group("Spread bomb skill")
@export var bomb_falling_time: float = 2.0
@export var bomb_count: int = 4
@export var bomb_spread_percentage: float = 0.3

@export_group("Rocket rain skill")
@export var rocket_falling_time: float = 2.0
@export var rocket_count: int = 4
@export var rocket_spread_percentage: float = 0.6

@export_group("Rocket launch skill")
@export var launch_count: int = 3
@export var launch_speed: float = 600

var start_bomb_period: float = 0.0
var bomb_interval: float = 0.0

var _bomb_factories: Node2D = null
var _bomb_fac_cursor: int = 0

var _smoke_rocket_factories: Node2D = null
var _follow_rocket_factories: Node2D = null

var _has_spread: bool = false
var _has_rocket_rain: bool = false
var _has_launched_rocket: bool = false

func _ready() -> void:
	super._ready()
	_init_shoot_bomb_state()
	_init_spread_bomb_state()
	_init_shoot_rocket_state()
	_init_spread_rocket_state()
	_init_bomb_factories()
	_init_rocket_factories()

func _init_rocket_factories():
	if has_node("Direction/RocketFactories/SmokeRocket"):
		_smoke_rocket_factories = get_node("Direction/RocketFactories/SmokeRocket")
	if has_node("Direction/RocketFactories/FollowRocket"):
		_follow_rocket_factories = get_node("Direction/RocketFactories/FollowRocket")

func _init_bomb_factories():
	if has_node("Direction/BombFactories"):
		_bomb_factories = get_node("Direction/BombFactories")
		_bomb_fac_cursor = 0

func _init_spread_rocket_state() -> void:
	if has_node("States/SpreadRocket"):
		var state : EnemyState = get_node("States/SpreadRocket")
		state.enter.connect(start_spread_rocket)
		state.exit.connect(end_spread_rocket)
		state.update.connect(update_spread_rocket)

func _init_shoot_rocket_state() -> void:
	if has_node("States/ShootRocket"):
		var state : EnemyState = get_node("States/ShootRocket")
		state.enter.connect(start_shoot_rocket)
		state.exit.connect(end_shoot_rocket)
		state.update.connect(update_shoot_rocket)

func _init_spread_bomb_state() -> void:
	if has_node("States/SpreadBomb"):
		var state : EnemyState = get_node("States/SpreadBomb")
		state.enter.connect(start_spread_bomb)
		state.exit.connect(end_spread_bomb)
		state.update.connect(update_spread_bomb)

func _init_shoot_bomb_state() -> void:
	if has_node("States/ShootBomb"):
		var state : EnemyState = get_node("States/ShootBomb")
		state.enter.connect(start_shoot_bomb)
		state.exit.connect(end_shoot_bomb)
		state.update.connect(update_shoot_bomb)
		
		var anim_speed = animated_sprite.sprite_frames.get_animation_speed("bomb")
		start_bomb_period = start_bomb_frame / anim_speed
		bomb_interval = bomb_frame_interval / anim_speed

func _init_skill_set():
	super._init_skill_set()
	_short_range_skills = [fsm.states.shootrocket, fsm.states.spreadrocket]
	_far_range_skills = [fsm.states.shootbomb, fsm.states.spreadbomb]

func start_spread_bomb() -> void:
	fsm.current_state.timer = start_bomb_period
	_has_spread = false
	change_animation("bomb")
	animated_sprite.animation_finished.connect(_return_to_normal)
	pass

func end_spread_bomb() -> void:
	animated_sprite.animation_finished.disconnect(_return_to_normal)
	pass

func update_spread_bomb(_delta) -> void:
	if fsm.current_state.update_timer(_delta):
		spread_bomb()
	if not found_player:
		_return_to_normal()
	pass

func spread_bomb() -> void:
	if _has_spread:
		return
	_has_spread = true
	spread(_bomb_factories.get_children(), bomb_count, bomb_falling_time, bomb_spread_percentage)

func spread(_factories: Array[Node], _count: int, _time_to_fall: float, _spread_pct: float) -> void:
	if _factories.is_empty():
		return
		
	var _computed_speed = compute_speed(_time_to_fall, found_player.position - self.position, gravity)
	var _rand_speed_x = RandomSpec.new(_computed_speed.x * (1 - _spread_pct) , _computed_speed.x * (1 + _spread_pct))
	var _rand_speed_y = RandomSpec.new(_computed_speed.y * (1 - _spread_pct) , _computed_speed.y * (1 + _spread_pct))
	for i in _count:
		var speed := Vector2(_rand_speed_x.get_random(), _rand_speed_y.get_random())
		var bullet = _factories.pick_random().create() as BaseBullet
		bullet.apply_velocity(speed)
		bullet.set_damage(spike)

func start_shoot_bomb() -> void:
	fsm.current_state.timer = start_bomb_period
	reload_bomb()
	change_animation("bomb")
	animated_sprite.animation_finished.connect(_return_to_normal)
	pass

func end_shoot_bomb() -> void:
	animated_sprite.animation_finished.disconnect(_return_to_normal)
	pass

func update_shoot_bomb(_delta) -> void:
	if fsm.current_state.update_timer(_delta):
		shoot_bomb()
		if not is_out_of_bombs():
			fsm.current_state.timer += bomb_interval
	if not found_player:
		_return_to_normal()
	pass

func shoot_bomb() -> void:
	if is_out_of_bombs():
		return
	shoot(_bomb_factories.get_children()[_bomb_fac_cursor])
	_bomb_fac_cursor += 1

func reload_bomb() -> void:
	_bomb_fac_cursor = 0

func is_out_of_bombs() -> bool:
	return _bomb_fac_cursor >= _bomb_factories.get_child_count()
	
func shoot(_factory: Node2DFactory) -> void:
	if not found_player:
		return
	
	var bomb = _factory.create() as BaseBullet
	bomb.apply_velocity(compute_shot_speed(_factory.global_position, found_player.position, shot_speed))
	bomb.set_damage(spike)
	bomb.set_gravity(0)

func start_spread_rocket() -> void:
	_has_rocket_rain = false
	fsm.current_state.timer = start_bomb_period
	change_animation("rocket")
	animated_sprite.animation_finished.connect(_return_to_normal)
	pass

func end_spread_rocket() -> void:
	animated_sprite.animation_finished.disconnect(_return_to_normal)
	pass

func update_spread_rocket(_delta) -> void:
	if fsm.current_state.update_timer(_delta):
		spread_rocket()
	if not found_player:
		_return_to_normal()
	pass

func spread_rocket() -> void:
	if _has_rocket_rain:
		return
	_has_rocket_rain = true
	spread(_smoke_rocket_factories.get_children(), rocket_count, rocket_falling_time, rocket_spread_percentage)

func start_shoot_rocket() -> void:
	_has_launched_rocket = false
	fsm.current_state.timer = start_bomb_period
	change_animation("rocket")
	animated_sprite.animation_finished.connect(_return_to_normal)
	pass

func end_shoot_rocket() -> void:
	animated_sprite.animation_finished.disconnect(_return_to_normal)
	pass

func update_shoot_rocket(_delta) -> void:
	if fsm.current_state.update_timer(_delta):
		launch_rocket()
	if not found_player:
		_return_to_normal()
	pass

func launch_rocket() -> void:
	if _has_launched_rocket:
		return
	_has_launched_rocket = true
	
	if not found_player:
		return

	for i in range(launch_count):
		var bullet = _follow_rocket_factories.get_children().pick_random().create() as FollowRocket
		bullet.set_launcher(self)
		bullet.set_target(found_player)
		bullet.apply_velocity(Vector2(launch_speed, launch_speed))
		bullet.set_damage(spike)
		bullet.set_gravity(0)
	pass
