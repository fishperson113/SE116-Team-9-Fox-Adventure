class_name StatefulEnemy
extends Enemy

enum InitialState { NORMAL, SLEEP }

@export var initial_state := InitialState.NORMAL

@export var hurt_time: float = 0.4
@export var awake_time: float = 2

func _ready() -> void:
	super._ready()
	_init_normal_state()
	_init_hurt_state()
	_init_dead_state()
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

func _init_normal_state() -> void:
	if has_node("States/Normal"):
		var state : EnemyState = get_node("States/Normal")
		state.enter.connect(start_normal)
		state.exit.connect(end_normal)
		state.update.connect(update_normal)

func _init_hurt_state() -> void:
	if has_node("States/Hurt"):
		var state : EnemyState = get_node("States/Hurt")
		state.enter.connect(start_hurt)
		state.exit.connect(end_hurt)
		state.update.connect(update_hurt)

func _init_dead_state() -> void:
	if has_node("States/Dead"):
		var state : EnemyState = get_node("States/Dead")
		state.enter.connect(start_dead)
		state.exit.connect(end_dead)
		state.update.connect(update_dead)

func start_normal() -> void:
	_movement_speed = movement_speed
	_near_sense_area.body_entered.connect(_on_normal_near_sense_body_entered)
	change_animation("normal")


func end_normal() -> void:
	_near_sense_area.body_entered.disconnect(_on_normal_near_sense_body_entered)
	pass

func update_normal(_delta: float) -> void:
	try_patrol_turn(_delta)
	pass

func start_hurt() -> void:
	_movement_speed = 0.0
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
	_near_sense_area.body_entered.connect(_on_sleep_near_sense_body_entered)
	pass

func end_sleep() -> void:
	_near_sense_area.body_entered.disconnect(_on_sleep_near_sense_body_entered)
	pass

func update_sleep(_delta: float) -> void:
	pass

func start_awaking() -> void:
	pass

func end_awaking() -> void:
	_hit_area_shape.disabled = false
	pass

func update_awaking(_delta: float) -> void:
	pass

func _on_sleep_near_sense_body_entered(_body) -> void:
	if _body is Player:
		fsm.change_state(fsm.states.awaking)

func _on_normal_near_sense_body_entered(_body) -> void:
	if _body is Player:
		target_player(_body)

func target_player(player: Player) -> void:
	var target_direction = -1
	if player.position.x > position.x:
		target_direction = 1
	
	if target_direction != direction:
		turn()
