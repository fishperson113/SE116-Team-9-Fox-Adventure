extends BaseCharacter

@export var break_time: float = 1
@export var fall_time: float = 2

var _is_broken: bool = false
var _gravity: float = 0.0

var _anim_player: AnimationPlayer = null

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_init_normal_state()
	_init_break_state()
	_init_fall_state()
	_init_dissolve_state()
	_init_initial_state()
	_init_trigger_area()
	_init_anim_player()
	pass

func _init_anim_player():
	if has_node("AnimationPlayer"):
		_anim_player = $AnimationPlayer
		_anim_player.animation_finished.connect(_on_animation_player_animation_finished)

func _init_trigger_area():
	if has_node("TriggerArea2D"):
		var trigger_area: Area2D = get_node("TriggerArea2D")
		trigger_area.body_entered.connect(_on_trigger_area_body_entered)
	pass

func _init_normal_state():
	if has_node("States/Normal"):
		var state : EnemyState = get_node("States/Normal")
		state.enter.connect(start_normal)
		state.exit.connect(end_normal)
		state.update.connect(update_normal)

func _init_break_state():
	if has_node("States/Break"):
		var state : EnemyState = get_node("States/Break")
		state.enter.connect(start_break)
		state.exit.connect(end_break)
		state.update.connect(update_break)

func _init_fall_state():
	if has_node("States/Fall"):
		var state : EnemyState = get_node("States/Fall")
		state.enter.connect(start_fall)
		state.exit.connect(end_fall)
		state.update.connect(update_fall)

func _init_dissolve_state():
	if has_node("States/Dissolve"):
		var state : EnemyState = get_node("States/Dissolve")
		state.enter.connect(start_dissolve)
		state.exit.connect(end_dissolve)
		state.update.connect(update_dissolve)

func _init_initial_state():
	fsm = FSM.new(self, $States, $States/Normal)

func _physics_process(delta: float) -> void:
	if fsm != null:
		fsm._update(delta)
	_update_movement(delta)

func _update_movement(delta: float) -> void:
	velocity.y += _gravity * delta
	move_and_slide()
	pass

func start_normal() -> void:
	pass

func end_normal() -> void:
	pass

func update_normal(_delta: float) -> void:
	if _is_broken:
		fsm.change_state(fsm.states.break)
	pass

func start_break() -> void:
	set_collision_layer_value(8, true)
	pass

func end_break() -> void:
	pass

func update_break(_delta: float) -> void:
	pass

func start_fall() -> void:
	_collision_shape.disabled = true
	_gravity = gravity
	_anim_player.play("falling")
	pass

func end_fall() -> void:
	pass

func update_fall(_delta: float) -> void:
	pass

func start_dissolve() -> void:
	queue_free()
	pass

func end_dissolve() -> void:
	pass

func update_dissolve(_delta: float) -> void:
	pass

func _on_trigger_area_body_entered(_body) -> void:
	_is_broken = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	fsm.change_state(fsm.states.dissolve)
