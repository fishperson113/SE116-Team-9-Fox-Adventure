extends Resource
class_name WeaponPartData

@export var id: String
@export var display_name: String

# "blade", "crossguard", "grip", "pommel"
@export_enum("blade", "crossguard", "grip", "pommel")
var type: String

@export var sprite: Texture2D
@export var height: int = 0
@export var uses_material: bool = false

# Mỗi part chỉ có đúng 1 stat tùy theo type
@export var damage: int = 0          # blade
@export var max_health: int = 0      # crossguard
@export var attack_speed: float = 0  # grip
@export var special_skill: String = ""  # pommel
