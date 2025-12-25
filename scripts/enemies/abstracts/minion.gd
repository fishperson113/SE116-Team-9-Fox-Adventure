class_name Minion
extends StatefulEnemy

enum InitialState { NORMAL, SLEEP }

@export var initial_state := InitialState.NORMAL

@export var hurt_time: float = 0.4
@export var awake_time: float = 2

func _ready() -> void:
	super._ready()
	_init_state("Hurt", start_hurt, end_hurt, update_hurt, _on_hurt_react)
	_init_state("Sleep", start_sleep, end_sleep, update_sleep, _on_normal_react)
	_init_state("Awaking", start_awaking, end_awaking, update_awaking, _on_normal_react)
	_init_initial_state()
	_setup_markers()
	pass

func _setup_markers():
	if _player_detected_marker:
		_player_detected_marker.set_trigger(is_player_visible)

func _init_initial_state() -> void:
	var state_node: EnemyState = $States/Normal
	match initial_state:
		InitialState.NORMAL:
			state_node = $States/Normal
		InitialState.SLEEP:
			state_node = $States/Sleep
		_:
			print("Unknown state %s", initial_state)
	
	fsm = FSM.new(self, $States, state_node)

func update_normal(_delta: float) -> void:
	if found_player:
		target(found_player.position)
	if is_player_visible():
		manage_attack_spacing()
		try_jump()
	else:
		move_forward()
		try_patrol_turn(_delta)
	pass

# Hurt state
func start_hurt() -> void:
	set_combat_collision(false)
	change_animation("hurt")
	if not animated_sprite.animation_finished.is_connected(try_recover):
		animated_sprite.animation_finished.connect(try_recover)

func end_hurt() -> void:
	set_combat_collision(true)
	if animated_sprite.animation_finished.is_connected(try_recover):
		animated_sprite.animation_finished.disconnect(try_recover)
	pass

func update_hurt(_delta: float) -> void:
	pass

# Sleep state
func start_sleep() -> void:
	_movement_speed = 0
	_detect_area_shape.disabled = true
	pass

func end_sleep() -> void:
	pass

func update_sleep(_delta: float) -> void:
	if found_player:
		fsm.change_state(fsm.states.awaking)
	pass

# Awaking state
func start_awaking() -> void:
	fsm.current_state.timer = awake_time
	pass

func end_awaking() -> void:
	_detect_area_shape.disabled = false
	pass

func update_awaking(_delta: float) -> void:
	if fsm.current_state.update_timer(_delta):
		fsm.change_state(fsm.states.normal)
	pass
