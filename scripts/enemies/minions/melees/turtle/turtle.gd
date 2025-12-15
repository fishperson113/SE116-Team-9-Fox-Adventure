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

# This will be random whenever hide state ends
var _low_health_threshold: int = 0

func _ready() -> void:
	super._ready()
	_init_state("Hiding", start_hiding, end_hiding, update_hiding, _on_normal_react)
	_init_state("Hide", start_hide, end_hide, update_hide, _on_hide_react)
	_init_state("Emerging", start_emerging, end_emerging, update_emerging, _on_normal_react)
	_setup_health_threshold()
	_setup_animation_speed()
	pass

func _setup_health_threshold() -> void:
	_low_health_threshold = _compute_low_health_threshold()

func _setup_animation_speed():
	animated_sprite.sprite_frames.set_animation_speed("hiding", _compute_anim_speed("hiding", transition_time))
	animated_sprite.sprite_frames.set_animation_speed("emerging", _compute_anim_speed("emerging", transition_time))

# Hiding state
func start_hiding():
	_movement_speed = 0
	change_animation("hiding")
	fsm.current_state.timer = transition_time
	pass

func end_hiding():
	pass

func update_hiding(_delta: float):
	if fsm.current_state.update_timer(_delta):
		fsm.change_state(fsm.states.hide)
	pass

# Hide state
func start_hide():
	change_animation("hide")
	fsm.current_state.timer = hide_time
	pass

func end_hide():
	_low_health_threshold = _compute_low_health_threshold()
	pass

func update_hide(_delta: float):
	if fsm.current_state.update_timer(_delta):
		fsm.change_state(fsm.states.emerging)
	pass

# Emerging state
func start_emerging():
	change_animation("emerging")
	fsm.current_state.timer = transition_time
	pass

func end_emerging():
	pass

func update_emerging(_delta: float):
	if fsm.current_state.update_timer(_delta):
		fsm.change_state(fsm.states.normal)
	pass

# Sleep state
func start_sleep() -> void:
	super.start_sleep()
	change_animation("sleep")
	pass

func update_sleep(_delta: float) -> void:
	super.update_sleep(_delta)
	if _is_hitted:
		fsm.change_state(fsm.states.awaking)
	pass

# Hurt state
func start_hurt() -> void:
	if is_alive() and is_health_warning():
		fsm.change_state(fsm.states.hiding)
		return
	super.start_hurt()

# Reaction
func _on_hide_react(input: BehaviorInput) -> void:
	if input is HurtBehaviorInput:
		reflect_damage(input.attacker, input.direction, input.damage_taken)

# Unique constraint
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

func try_jump() -> bool:
	if not is_touch_wall():
		return false
	
	if _front_ray_cast.get_collider() is Minion:
		return false
	
	# Jump if there are no obstacles above
	if not _jump_raycast.is_colliding():
		jump()
		return true
	# Jump onto player
	if _jump_raycast.get_collider() is Player:
		jump()
		return true
	
	return false
