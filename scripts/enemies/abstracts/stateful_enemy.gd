class_name StatefulEnemy
extends Enemy

func _ready() -> void:
	super._ready()
	_init_normal_state()
	_init_dead_state()
	_init_initial_state()
	pass

func _init_initial_state() -> void:
	var state_node = $States/Normal
	fsm = FSM.new(self, $States, state_node)

func _init_normal_state() -> void:
	if has_node("States/Normal"):
		var state : EnemyState = get_node("States/Normal")
		state.enter.connect(start_normal)
		state.exit.connect(end_normal)
		state.update.connect(update_normal)

func _init_dead_state() -> void:
	if has_node("States/Dead"):
		var state : EnemyState = get_node("States/Dead")
		state.enter.connect(start_dead)
		state.exit.connect(end_dead)
		state.update.connect(update_dead)

func start_normal() -> void:
	_movement_speed = movement_speed
	change_animation("normal")

func end_normal() -> void:
	pass

func update_normal(_delta: float) -> void:
	pass

func start_dead() -> void:
	queue_free()

func end_dead() -> void:
	pass

func update_dead(_delta: float) -> void:
	pass

func target(_position: Vector2) -> void:
	if _compute_target_direction(_position) != direction:
		turn()

func _compute_target_direction(_position: Vector2) -> int:
	var target_direction = -1
	if _position.x > position.x:
		target_direction = 1
	return target_direction
