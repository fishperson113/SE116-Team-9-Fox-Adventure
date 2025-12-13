extends Resource
class_name WeaponData

@export var blade: WeaponPartData
@export var crossguard: WeaponPartData
@export var grip: WeaponPartData
@export var pommel: WeaponPartData

@export var material: WeaponMaterialData

@export var png_path: String = ""
@export var current_durability: float = -1.0
@export var weapon_name:String= ""
# --- Final stats ---
func get_damage() -> int:
	return blade.damage if blade else 0

func get_max_health() -> int:
	return crossguard.max_health if crossguard else 0

func get_knock_back_force() -> float:
	return grip.knock_back_force if grip else 1.0

func get_special_skill() -> String:
	return pommel.special_skill if pommel else ""

func get_color() -> Color:
	return material.color if material else Color.WHITE
func get_durability()-> float:
	if current_durability < 0 and material:
		return float(material.durability)
	return current_durability
	
func reduce_durability(amount: float) -> float:
	if current_durability < 0 and material:
		current_durability = float(material.durability)
	
	current_durability -= amount
	return current_durability <= 0
