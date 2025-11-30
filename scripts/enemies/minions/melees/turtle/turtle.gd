extends Minion

#Mô tả:
#Đi qua đi lại trong 1 phạm vi nhất định
#Tự động thu mình vào mai trong 3 giây
#Người chơi chạm vào rùa hoặc mai rùa đều sẽ mất máu theo Spike
#Mai rùa không thể bị phá huỷ
#Ở trong mai 3 giây rùi lại chui ra

@export var reflect_percentage: float = 0.5
@export var max_tolerable_pct: float = 0.3

@export var normal_time: float = 3.0
@export var transition_time: float = 0.25
@export var hide_time: float = 3.0

var _is_hitted: bool = false
# This will be random whenever hide state ends
var _low_health_threshold: int = 0

var _anim: AnimatedSprite2D = null

func _ready() -> void:
	super._ready()
	_init_hiding_state()
	_init_hide_state()
	_init_emerging_state()
	_init_anim()
	pass

func _init_anim():
	_anim = $Direction/AnimatedSprite2D
	_compute_anim_speed("hiding", transition_time)
	_compute_anim_speed("emerging", transition_time)

func _init_hiding_state() -> void:
	if has_node("States/Hiding"):
		var state : EnemyState = get_node("States/Hiding")
		state.enter.connect(start_hiding)

func _init_hide_state() -> void:
	if has_node("States/Hide"):
		var state : EnemyState = get_node("States/Hide")
		state.enter.connect(start_hide)
		state.exit.connect(end_hide)
		_low_health_threshold = _compute_low_health_threshold()

func _init_emerging_state() -> void:
	if has_node("States/Emerging"):
		var state : EnemyState = get_node("States/Emerging")
		state.enter.connect(start_emerging)

func start_hide():
	change_animation("hide")
	pass

func end_hide():
	_low_health_threshold = _compute_low_health_threshold()
	pass

func start_hiding():
	_movement_speed = 0
	change_animation("hiding")
	pass

func start_emerging():
	change_animation("emerging")
	pass

func start_sleep() -> void:
	_movement_speed = 0
	_detect_area_shape.disabled = true
	change_animation("sleep")
	pass

func update_sleep(_delta: float) -> void:
	super.update_sleep(_delta)
	if _is_hitted:
		fsm.change_state(fsm.states.awaking)
	pass

func _on_hit_area_2d_hitted(body):
	super._on_hit_area_2d_hitted(body)
	_is_hitted = true
	pass

func reflect_damage(_attacker: BaseCharacter, _direction: Vector2, _damage: float) -> void:
	if _attacker.has_method("_on_hurt_area_2d_hurt"):
		_attacker._on_hurt_area_2d_hurt(self, _direction * -1, int(_compute_reflect_damage(_damage)))

func _compute_reflect_damage(_damage: float) -> float:
	return _damage * reflect_percentage

func _compute_low_health_threshold() -> int:
	var _max_tolerable_amount: int = int(max_tolerable_pct * currentHealth)
	var _min_tolerable_threshold: int = max(0, currentHealth - _max_tolerable_amount)
	var result = randi_range(_min_tolerable_threshold, int(currentHealth))
	return result

func is_health_warning() -> bool:
	return currentHealth <= _low_health_threshold

func _compute_anim_speed(_anim_name: String, duration: float) -> void:
	if _anim:
		var frame_count = _anim.sprite_frames.get_frame_count(_anim_name)
		_anim.sprite_frames.set_animation_speed(_anim_name, frame_count / duration)

func start_hurt() -> void:
	if is_health_warning():
		fsm.change_state(fsm.states.hiding)
		return
	super.start_hurt()
