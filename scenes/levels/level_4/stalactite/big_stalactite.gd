extends BaseCharacter

@export var shake_time: float = 4
@export var damage: float = 200
@export var max_distance: float = 600

var _gravity: float = 0.0

var _body: Node2D = null
var _raycast: RayCast2D = null

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_init_normal_state()
	_init_shake_state()
	_init_fall_state()
	_init_lay_state()
	_init_initial_state()
	_init_hit_area()
	_init_raycast()
	pass

func _init_raycast():
	_raycast = $RayCast2D
	_raycast.target_position.y = max_distance

func _init_hit_area():
	if has_node("HitArea2D"):
		var hit_area := $HitArea2D
		hit_area.set_dealt_damage(damage)
		hit_area.body_entered.connect(_on_hit_area_body_entered)

func _init_normal_state():
	if has_node("States/Normal"):
		var state : EnemyState = get_node("States/Normal")
		state.enter.connect(start_normal)
		state.exit.connect(end_normal)
		state.update.connect(update_normal)

func _init_shake_state():
	if has_node("States/Shake"):
		var state : EnemyState = get_node("States/Shake")
		state.enter.connect(start_shake)
		state.exit.connect(end_shake)
		state.update.connect(update_shake)

func _init_fall_state():
	if has_node("States/Fall"):
		var state : EnemyState = get_node("States/Fall")
		state.enter.connect(start_fall)
		state.exit.connect(end_fall)
		state.update.connect(update_fall)

func _init_lay_state():
	if has_node("States/Lay"):
		var state : EnemyState = get_node("States/Lay")
		state.enter.connect(start_lay)
		state.exit.connect(end_lay)
		state.update.connect(update_lay)

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
	if can_fall():
		fsm.change_state(fsm.states.shake)
	pass

func start_shake() -> void:
	velocity.y = 1
	pass

func end_shake() -> void:
	pass

func update_shake(_delta: float) -> void:
	pass

func start_fall() -> void:
	_gravity = gravity
	pass

func end_fall() -> void:
	pass

func update_fall(_delta: float) -> void:
	if _body is TileMapLayer:
		fsm.change_state(fsm.states.lay)
	pass

func start_lay() -> void:
	$HitArea2D/CollisionShape2D.disabled = true
	set_collision_layer_value(1, true)
	pass

func end_lay() -> void:
	pass

func update_lay(_delta: float) -> void:
	pass

func can_fall() -> bool:
	if not _raycast.is_colliding():
		return false

	if not _raycast.get_collider() is Player:
		_raycast.target_position.y = _raycast.get_collision_point().y - _raycast.global_position.y
		return false
	
	return true

func _on_hit_area_body_entered(body):
	_body = body
	pass
