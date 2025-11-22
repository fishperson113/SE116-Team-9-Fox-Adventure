class_name WeaponEquipmentManager
extends Node

var blade: WeaponPartData = null
var crossguard: WeaponPartData = null
var grip: WeaponPartData = null
var pommel: WeaponPartData = null

var material_color: Color = Color.WHITE

func clear():
	blade = null
	crossguard = null
	grip = null
	pommel = null
	material_color = Color.WHITE

func equip_parts(parts: Array[WeaponPartData], material: Color):
	clear()
	material_color = material

	for p in parts:
		match p.type:
			"blade": blade = p
			"crossguard": crossguard = p
			"grip": grip = p
			"pommel": pommel = p

# ----------- EXPOSED FINAL STATS ----------------
func get_damage():
	return blade.damage if blade else 0

func get_max_health():
	return crossguard.max_health if crossguard else 0

func get_attack_speed():
	return grip.attack_speed if grip else 1.0

func get_special_skill():
	return pommel.special_skill if pommel else ""

func can_double_jump():
	return pommel.special_skill == "double_jump"
