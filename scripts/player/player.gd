class_name Player
extends BaseCharacter

var hit_buffer: bool = false
@export var character_type = 0

var weapon_thrower: WeaponThrower

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	weapon_thrower = $WeaponThrower
	super._ready()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("change_form"):
		var new_type: int
		if character_type == 3:
			new_type = 0
		else:
			new_type = character_type + 1
		change_player_type(new_type)

func change_player_type(char_type: int) -> void:
	var animation_reset = get_reset_animation_name(current_animation)
	character_type = char_type
	change_animation(animation_reset)

func get_animation_prefix() -> String:
	var char_type: String
	
	if character_type == 0: char_type = ""
	elif character_type == 1: char_type = "hat_"
	elif character_type == 2: char_type = "blade_"
	elif character_type == 3: char_type = "hat_blade_"
	
	return char_type

func change_animation(new_animation: String) -> void:
	if new_animation == "attack" and character_type == 0:
		return
	
	var char_type = get_animation_prefix()
	_next_animation = char_type + new_animation

func get_reset_animation_name(animation_name: String) -> String:
	var next_name: String = animation_name
	var char_type = get_animation_prefix()
	
	next_name = next_name.replace(char_type, "")
	return next_name
