class_name Minion
extends StatefulEnemy

enum InitialState { NORMAL, SLEEP }

@export var initial_state := InitialState.NORMAL

@export var hurt_time: float = 0.4
@export var awake_time: float = 2

@export var idle_chance: float = 0.001

func _ready() -> void:
	super._ready()
	_init_idle_state()
	_init_hurt_state()
	_init_sleep_state()
	_init_awaking_state()
	_init_initial_state()
	pass

func _init_initial_state() -> void:
	var state_node: EnemyState = null
	match initial_state:
		InitialState.NORMAL:
			state_node = $States/Normal
		InitialState.SLEEP:
			state_node = $States/Sleep
		_:
			print("Unknown state %s", initial_state)
	
	fsm = FSM.new(self, $States, state_node)

func _init_idle_state() -> void:
	if has_node("States/Idle"):
		var state : EnemyState = get_node("States/Idle")
		state.enter.connect(start_idle)
		state.exit.connect(end_idle)
		state.update.connect(update_idle)

func _init_awaking_state() -> void:
	if has_node("States/Awaking"):
		var state : EnemyState = get_node("States/Awaking")
		state.enter.connect(start_awaking)
		state.exit.connect(end_awaking)
		state.update.connect(update_awaking)

func _init_sleep_state() -> void:
	if has_node("States/Sleep"):
		var state : EnemyState = get_node("States/Sleep")
		state.enter.connect(start_sleep)
		state.exit.connect(end_sleep)
		state.update.connect(update_sleep)

func _init_hurt_state() -> void:
	if has_node("States/Hurt"):
		var state : EnemyState = get_node("States/Hurt")
		state.enter.connect(start_hurt)
		state.exit.connect(end_hurt)
		state.update.connect(update_hurt)

func update_normal(_delta: float) -> void:
	try_patrol_turn(_delta)
	if found_player:
		target(found_player.position)
	#if try_patrol_turn(_delta) or randf() < idle_chance:
		#fsm.change_state(fsm.states.idle)
	pass

func start_hurt() -> void:
	#_movement_speed = 0.0
	change_animation("hurt")

func end_hurt() -> void:
	pass

func update_hurt(_delta: float) -> void:
	pass

func start_dead() -> void:
	queue_free()

func end_dead() -> void:
	pass

func update_dead(_delta: float) -> void:
	pass

func start_sleep() -> void:
	_movement_speed = 0
	_hit_area_shape.disabled = true
	_detect_area_shape.disabled = true
	pass

func end_sleep() -> void:
	pass

func update_sleep(_delta: float) -> void:
	if found_player:
		fsm.change_state(fsm.states.awaking)
	pass

func start_awaking() -> void:
	pass

func end_awaking() -> void:
	_hit_area_shape.disabled = false
	_detect_area_shape.disabled = false
	pass

func update_awaking(_delta: float) -> void:
	pass

func start_idle() -> void:
	_movement_speed = 0.0
	change_animation("idle")
	pass

func end_idle() -> void:
	pass

func update_idle(_delta: float) -> void:
	if randf() < idle_chance:
		fsm.change_state(fsm.states.normal)
	pass
