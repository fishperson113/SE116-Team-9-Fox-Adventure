class_name StatefulEnemy
extends Enemy

func _ready() -> void:
	super._ready()
	_init_state("Normal", start_normal, end_normal, update_normal, _on_normal_react)
	_init_state("Dead", start_dead, end_dead, update_dead, _on_hurt_react)
	_init_initial_state()
	pass

func _init_initial_state() -> void:
	var state_node = $States/Normal
	fsm = FSM.new(self, $States, state_node)

func _init_state(
	state_name: String,
	on_enter: Callable,
	on_exit: Callable,
	on_update: Callable,
	on_react: Callable
) -> void:
	var path := "States/" + state_name
	if not has_node(path):
		return
	
	var state: EnemyState = get_node(path)
	state.enter.connect(on_enter)
	state.exit.connect(on_exit)
	state.update.connect(on_update)
	state.react.connect(on_react)

# Normal state
func start_normal() -> void:
	_movement_speed = movement_speed
	change_animation("normal")

func end_normal() -> void:
	pass

func update_normal(_delta: float) -> void:
	pass

# Dead state
func start_dead() -> void:
	clear_area_collision(_hit_area)
	clear_area_collision(_hurt_area)
	clear_area_collision(_detect_player_area)
	clear_area_collision(_near_sense_area)
	LootSystem.spawn_loot(self)
	queue_free()

func end_dead() -> void:
	pass

func update_dead(_delta: float) -> void:
	pass

# Reaction
func _on_normal_react(input: BehaviorInput) -> void:
	if input is HurtBehaviorInput:
		take_damage_behavior(input.attacker, input.direction, input.damage_taken)

func _on_hurt_react(input: BehaviorInput) -> void:
	# Do nothing
	pass

# Unique constraint
func _return_to_normal() -> void:
	fsm.change_state(fsm.states.normal)
