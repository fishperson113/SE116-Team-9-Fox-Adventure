extends Resource
class_name WeaponData

@export var blade: WeaponPartData
@export var crossguard: WeaponPartData
@export var grip: WeaponPartData
@export var pommel: WeaponPartData

@export var material: WeaponMaterialData

@export var png_path: String = ""

# --- Final stats ---
func get_damage() -> int:
	return blade.damage if blade else 0

func get_max_health() -> int:
	return crossguard.max_health if crossguard else 0

func get_attack_speed() -> float:
	return grip.attack_speed if grip else 1.0

func get_special_skill() -> String:
	return pommel.special_skill if pommel else ""

func get_color() -> Color:
	return material.color if material else Color.WHITE
