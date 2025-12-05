extends CharacterBody2D
class_name BaseWeapon

var hit_area: HitArea2D

var _velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO
@export var speed: float
@export var gravity: float
@export var spin_speed: float #tốc độ quay được tính bằng độ

#General properties of a weapon
#MUST include damage, erosion_rate
var weapon_detail: Resource

@export var sample_collectible_weapon: PackedScene

func _init() -> void:
	hit_area = $Direction/HitArea2D
	pass

func _ready() -> void:
	_velocity = dir * speed

func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	print(weapon_detail)
	queue_free()
	pass # Replace with function body.

func add_general_weapon_properties(weapon_detail: Resource) -> void:
	self.weapon_detail = weapon_detail.duplicate(true)

func set_dealt_damage(dealt_damage: float) -> void:
	hit_area.set_dealt_damage(dealt_damage)
