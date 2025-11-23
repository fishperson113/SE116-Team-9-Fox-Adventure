extends BaseCharacter

@export var shake_time: float = 1
@export var damage: float = 50
@export var max_distance: float = 600

var _body: Node2D = null
var _gravity: float = 0.0

var _anim_player: AnimationPlayer = null
var _raycast: RayCast2D = null

@onready var _drop_factory: Node2DFactory = $DropFactory

func _ready() -> void:
	_init_normal_state()
	_init_melt_state()
	_init_shake_state()
	_init_fall_state()
	_init_dissolve_state()
	_init_initial_state()
	_init_anim_player()
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

func _init_anim_player():
	if has_node("AnimationPlayer"):
		_anim_player = $AnimationPlayer
		_anim_player.animation_finished.connect(_on_animation_player_animation_finished)

func _init_normal_state():
	if has_node("States/Normal"):
		var state : EnemyState = get_node("States/Normal")
		state.enter.connect(start_normal)
		state.exit.connect(end_normal)
		state.update.connect(update_normal)

func _init_melt_state():
	if has_node("States/Melt"):
		var state : EnemyState = get_node("States/Melt")
		state.enter.connect(start_melt)
		state.exit.connect(end_melt)
		state.update.connect(update_melt)

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
	if can_fall():
		fsm.change_state(fsm.states.melt)
	pass

func start_melt() -> void:
	drip()
	pass

func end_melt() -> void:
	_body = null
	pass

func update_melt(_delta: float) -> void:
	if not _body:
		return
		
	if _body is Player:
		fsm.change_state(fsm.states.shake)
	else:
		fsm.change_state(fsm.states.normal)
	pass

func start_shake() -> void:
	velocity.y = 5
	pass

func end_shake() -> void:
	pass

func update_shake(_delta: float) -> void:
	pass

func start_fall() -> void:
	_gravity = gravity
	pass

func end_fall() -> void:
	_body = null
	pass

func update_fall(_delta: float) -> void:
	if not _body:
		return
	
	if _body.is_in_group("ground"):
		fsm.change_state(fsm.states.dissolve)
	pass

func start_dissolve() -> void:
	_anim_player.play("dissolving")
	$HitArea2D/CollisionShape2D.disabled = true
	pass

func end_dissolve() -> void:
	pass

func update_dissolve(_delta: float) -> void:
	pass

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()

func can_fall() -> bool:
	if not _raycast.is_colliding():
		return false

	if not _raycast.get_collider() is Player:
		_raycast.target_position.y = _raycast.get_collision_point().y - _raycast.global_position.y
		return false
	
	return true

func drip():
	var drop = _drop_factory.create() as Droplet
	drop.hit.connect(_on_droplet_hit)
	pass

func _on_droplet_hit(body):
	_body = body

func _on_hit_area_body_entered(body):
	_body = body
	pass
