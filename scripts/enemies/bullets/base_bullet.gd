class_name BaseBullet
extends BaseCharacter

@export var explosion_effect: PackedScene = null

var _hit_area: HitArea2D = null

var _gravity: float = gravity

func _ready() -> void:
	_init_hit_area()

func _init_hit_area():
	if has_node("Direction/HitArea2D"):
		_hit_area = $Direction/HitArea2D
	elif has_node("HitArea2D"):
		_hit_area = $HitArea2D
	_hit_area.body_entered.connect(_on_body_entered)
	_hit_area.hitted.connect(_on_hitted)

func _physics_process(_delta: float) -> void:
	pass

func _process(_delta: float) -> void:
	velocity.y += _gravity * _delta
	move_and_slide()

func set_damage(damage: float) -> void:
	_hit_area.set_dealt_damage(damage)

func apply_velocity(fire_velocity: Vector2) -> void:
	velocity = fire_velocity

func set_gravity(_g: float):
	_gravity = _g

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
	
	var created_effect = create(explosion_effect, global_position)
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
