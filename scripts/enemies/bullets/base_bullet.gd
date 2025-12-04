class_name BaseBullet
extends BaseCharacter

@export var explosion_effect: PackedScene = null
@export var container_name: String = "Bullets"

var _hit_area: HitArea2D = null
var _effect_factory: PackedSceneFactory = null

# These attributes can be changed
var _gravity: float = gravity

func _ready() -> void:
	super._ready()
	_effect_factory = PackedSceneFactory.new(self)
	_init_hit_area()

func _init_hit_area():
	if has_node("Direction/HitArea2D"):
		_hit_area = $Direction/HitArea2D
		_hit_area.body_entered.connect(_on_body_entered)
		_hit_area.hitted.connect(_on_hitted)

func _physics_process(delta: float) -> void:
	# Animation
	_check_changed_animation()
	
	if fsm != null:
		fsm._update(delta)
	# Movement
	_update_movement(delta)
	# Direction
	_check_changed_direction()

func _update_movement(_delta: float) -> void:
	velocity.y += _gravity * _delta
	move_and_slide()

func set_damage(damage: float) -> void:
	_hit_area.set_dealt_damage(damage)

func apply_velocity(fire_velocity: Vector2) -> void:
	velocity = fire_velocity

func set_gravity(_new_gravity: float):
	_gravity = _new_gravity

func _on_body_entered(_body):
	explosion()
	pass

func _on_hitted(_area):
	pass

func explosion() -> void:
	call_deferred("create_effect")
	queue_free()

func create_effect():
	if not explosion_effect:
		return
	
	var created_effect = _effect_factory.create(explosion_effect, container_name, global_position)
	created_effect.z_index = 1
	if created_effect is GPUParticles2D:
		created_effect.emitting = true
	if created_effect.has_method("set_damage"):
		created_effect.set_damage(_hit_area._dealt_damage)

func create(_packed_scene: PackedScene, _position: Vector2):
	if not _packed_scene:
		return
	
	var scene: Node2D = _packed_scene.instantiate()
	scene.global_position = _position
	
	get_tree().current_scene.add_child(scene)
	return scene
